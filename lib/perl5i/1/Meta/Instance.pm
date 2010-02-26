package perl5i::1::Meta::Instance;

use strict;
use warnings;

require Scalar::Util;
require overload;
require Carp;

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

1;
