# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::HASH;
use 5.010;

use strict;
use warnings;
use Carp;

sub HASH::flip {

    croak "Can't flip hash with references as values"
        if grep { ref } values %{$_[0]};

    return { reverse %{$_[0]} };
}

1;
