package perl5i::2::Meta::Class;

# Methods here are for $thing->mc->method.

use strict;
use warnings;

use parent qw(perl5i::2::Meta);

sub class {
    return ref ${${$_[0]}} ? ref ${${$_[0]}} : ${${$_[0]}};
}

sub reftype {
    return;
}

1;
