# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::ARRAY;
use 5.010;

use strict;
use warnings;

sub ARRAY::grep {
    my ( $array, $filter ) = @_;

    return [ CORE::grep { $_ ~~ $filter } @$array ];
}

sub ARRAY::all {
    require List::MoreUtils;
    return List::MoreUtils::all($_[1], @{$_[0]});
}

sub ARRAY::any {
    require List::MoreUtils;
    return List::MoreUtils::any($_[1], @{$_[0]});
}

sub ARRAY::none {
    require List::MoreUtils;
    return List::MoreUtils::none($_[1], @{$_[0]});
}

sub ARRAY::true {
    require List::MoreUtils;
    return List::MoreUtils::true($_[1], @{$_[0]});
}

sub ARRAY::false {
    require List::MoreUtils;
    return List::MoreUtils::false($_[1], @{$_[0]});
}

sub ARRAY::uniq {
    require List::MoreUtils;
    return [ List::MoreUtils::uniq(@{$_[0]}) ];
}

sub ARRAY::minmax {
    require List::MoreUtils;
    return [ List::MoreUtils::minmax(@{$_[0]}) ];
}

sub ARRAY::mesh {
    require List::MoreUtils;
    return [ List::MoreUtils::zip(@_) ];
}

sub ARRAY::diff {
    require List::MoreUtils;

    my $original = shift;

    my @lumped = List::MoreUtils::uniq(map { "$_" } map { @$_ } @_ );

    my @result = grep { not $_ ~~ @lumped } @$original;

    return \@result;
}

1;
