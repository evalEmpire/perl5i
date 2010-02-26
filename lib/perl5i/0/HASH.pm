# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::HASH;
use 5.010;

use strict;
use warnings;
use Carp;

sub HASH::flip {
    croak "Can't flip hash with references as values"
        if grep { ref } values %{$_[0]};

    my %flipped = reverse %{$_[0]};

    return wantarray ? %flipped : \%flipped;
}

sub HASH::merge {
    require Hash::Merge::Simple;
    my $merged = Hash::Merge::Simple::merge(@_);

    return wantarray ? %$merged : $merged;
}

1;
