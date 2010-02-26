# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::ARRAY;
use 5.010;

use strict;
use warnings;
use Carp;

sub ARRAY::first {
    my ( $array, $filter ) = @_;

    # Deep recursion and segfault (lines 90 and 91 in first.t) if we use
    # the same elegant approach as in ARRAY::grep().
    if ( ref $filter eq 'Regexp' ) {
        return List::Util::first( sub { $_ ~~ $filter }, @$array );
    }

    return List::Util::first( sub { $filter->() }, @$array );

}

sub ARRAY::grep {
    my ( $array, $filter ) = @_;

    my @result = CORE::grep { $_ ~~ $filter } @$array;

    return wantarray ? @result : \@result;
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
    my @uniq = List::MoreUtils::uniq(@{$_[0]});
    return wantarray ? @uniq : \@uniq;
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

    my ($first, $second) = @_;

    return $first unless $second;

    croak "Can't handle nested data structures yet"
        if grep { ref } map { @$_ } ($first, $second);

    require Array::Diff;
    return Array::Diff->diff($first, $second)->deleted;
}

1;

