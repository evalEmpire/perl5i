package perl5i::1::Meta::Instance;

use strict;
use warnings;

require Scalar::Util;
require overload;
require Carp;

use perl5i::1::autobox;

use parent qw(perl5i::1::Meta);

sub class {
    return ref ${$_[0]};
}

sub reftype {
    return Scalar::Util::reftype(${$_[0]});
}


# Only instances can be tainted

# Returns the code which will run when the object is used as a string
my $has_string_overload = sub {
    return overload::Method(${$_[0]}, q[""]) || overload::Method(${$_[0]}, q[0+])
};

sub is_tainted {
    my $code;

    if( $code = $_[0]->$has_string_overload ) {
        require Taint::Util;
        return Taint::Util::tainted( $code->(${$_[0]}) );
    }
    else {
        return 0;
    }

    die "Never should be reached";
}


sub taint {
    if( $_[0]->$has_string_overload ) {
        Carp::croak "Untainted overloaded objects cannot normally be made tainted" if
          !$_[0]->is_tainted;
        return 1;
    }
    else {
        Carp::croak "Only scalars can normally be made tainted";
    }

    Carp::confess "Should not be reached";
}


sub untaint {
    if( $_[0]->$has_string_overload && $_[0]->is_tainted ) {
        Carp::croak "Tainted overloaded objects cannot normally be untainted";
    }
    else {
        return 1;
    }

    Carp::confess "Should never be reached";
}


sub checksum {
    my( $thing, %args ) = @_;

    my $algorithms = [qw(sha1 md5)];
    $args{algorithm} //= 'sha1';
    $args{algorithm} ~~ $algorithms or
      Carp::croak("algorithm must be @{[ $algorithms->join(' or ' ) ]}");

    my $algorithm2module = { sha1 => "Digest::SHA", md5 => "Digest::MD5" };

    my $format = [qw(hex base64 binary)];
    $args{format} //= 'hex';
    $args{format} ~~ $format or
      Carp::croak("format must be @{[ $format->join(' or ') ]}");

    my %prefix = ( hex => 'hex', base64 => 'b64', binary => undef );

    my $module = $algorithm2module->{ $args{algorithm} };
    my $digest = defined $prefix{ $args{format} } ? $prefix{ $args{format} } . 'digest' : 'digest';

    Module::Load::load($module);
    my $digestor = $module->new;

    require Data::Dumper;

    my $d = Data::Dumper->new( [ ${$thing} ] );
    $d->Deparse(1)->Terse(1)->Sortkeys(1)->Indent(0);

    $digestor->add( $d->Dump );
    return $digestor->$digest;
}

1;
