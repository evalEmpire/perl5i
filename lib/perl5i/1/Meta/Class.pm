package perl5i::1::Meta::Class;

use strict;
use warnings;

use parent qw(perl5i::1::Meta);

sub class {
    return ${$_[0]};
}

sub reftype {
    return;
}

1;
