# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::ARRAY;
use 5.010;

use strict;
use warnings;
use Module::Load;

sub ARRAY::grep {
    my ( $array, $filter ) = @_;

    if ( ref $filter eq 'Regexp' ) {
        return [ CORE::grep /$filter/, @$array ];
    }

    return [ CORE::grep { $filter->($_) } @$array ];
}

sub ARRAY::all {
    load List::MoreUtils;
    return List::MoreUtils::all($_[1], @{$_[0]});
}

sub ARRAY::any {
    load List::MoreUtils;
    return List::MoreUtils::any($_[1], @{$_[0]});
}

sub ARRAY::none {
    load List::MoreUtils;
    return List::MoreUtils::none($_[1], @{$_[0]});
}

sub ARRAY::true {
    load List::MoreUtils;
    return List::MoreUtils::true($_[1], @{$_[0]});
}

sub ARRAY::false {
    load List::MoreUtils;
    return List::MoreUtils::false($_[1], @{$_[0]});

}

sub ARRAY::uniq {
    load List::MoreUtils;
    return [ List::MoreUtils::uniq(@{$_[0]}) ];
}

sub ARRAY::minmax {
    load List::MoreUtils;
    return [ List::MoreUtils::minmax(@{$_[0]}) ];
}

*ARRAY::range = *ARRAY::minmax;

sub ARRAY::zip {
    load List::MoreUtils;
    return [ List::MoreUtils::zip(@_) ];
}

*ARRAY::mesh = *ARRAY::zip;

1;
