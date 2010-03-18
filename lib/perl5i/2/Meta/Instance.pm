package perl5i::2::Meta::Instance;

use v5.10;
use strict;
use warnings;

require Scalar::Util;
require overload;
require Carp;

use perl5i::2::autobox;

use parent qw(perl5i::2::Meta);

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

    my $format = [qw(hex base64 binary)];
    $args{format} //= 'hex';
    $args{format} ~~ $format or
      Carp::croak("format must be @{[ $format->join(' or ') ]}");

    my %prefix = ( hex => 'hex', base64 => 'b64', binary => undef );

    my $module = 'Digest::' . uc $args{algorithm};
    my $digest = defined $prefix{ $args{format} } ? $prefix{ $args{format} } . 'digest' : 'digest';

    $module->require;
    my $digestor = $module->new;

    require Data::Dumper;

    my $d = Data::Dumper->new( [ ${$thing} ] );
    $d->Deparse(1)->Terse(1)->Sortkeys(1)->Indent(0);

    $digestor->add( $d->Dump );
    return $digestor->$digest;
}


sub is_equal {
    my ($self, $other) = @_;
    require perl5i::2::equal;

    return perl5i::2::equal::are_equal(${$self}, $other);
}


sub perl {
    require Data::Dumper;

    state $options = [qw(Terse Sortkeys Deparse)];

    my $self = shift;
    my $dumper = Data::Dumper->new([${$self}]);
    for my $option (@$options) {
        $dumper->$option(1);
    }

    $dumper->Indent(1);

    return $dumper->Dump;
}


sub dump {
    my $self = shift;
    my %args = @_;

    my $format = $args{format} // "perl";
    state $dumpers = {
        json    => "_dump_as_json",
        yaml    => "_dump_as_yaml",
        perl    => "perl",
    };

    my $dumper = $dumpers->{$format};
    Carp::croak "Unknown format '$format' for dump()" unless $dumper;

    return $self->$dumper(%args);
}


sub _dump_as_json {
    require JSON;
    my $json = JSON->new
                    ->utf8
                    ->pretty
                    ->allow_unknown
                    ->allow_blessed
                    ->convert_blessed;

    # JSON doesn't seem to have an easy way to say
    # "just dump objects as references please".  This is their
    # recommended way to do it (yarf).
    local *UNIVERSAL::TO_JSON = sub {
        require B;
        my $b_obj = B::svref_2object( $_[0] );
        return  $b_obj->isa('B::HV') ? { %{ $_[0] } }
              : $b_obj->isa('B::AV') ? [ @{ $_[0] } ]
              : undef
              ;
    } unless defined &UNIVERSAL::TO_JSON;

    return $json->encode(${$_[0]});
}

sub _dump_as_yaml {
    require YAML::Any;
    return YAML::Any::Dump(${$_[0]});
}

1;
