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
    my ($base, @rest) = @_;
    return $base unless (@rest);

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = _diff_two($base, $array);
    }

    return $base;
}

sub _diff_two {
    # Compare differences between two arrays.
    my ($c, $d) = @_;

    my $diff;

    return    if not defined $c;
    return $c if not defined $d;

    # For each element of $c, try to find if it is equal to any of the
    # elements of $d. If not, it's unique, and has to be pushed into
    # $diff.

    require List::MoreUtils;
    foreach my $item (@$c) {
        unless (
            # for some reason, any { foo() } @bar complains
            List::MoreUtils::any( sub { _are_equal( $item, $_ ) }, @$d )
        )
        {
            push @$diff, $item;
        }
    }

    return $diff;
}

sub _are_equal {
    my ($r1, $r2) = @_;

    # given two scalars, decide whether they are identical or not,
    # recursing over deep data structures. Since it uses recursion,
    # traversal is done depth-first.

    return if !defined $r1 or !defined $r2;


    if (ref $r1 eq 'ARRAY' and ref $r2 eq 'ARRAY') {
        # They can only be equal if they have the same nº of elements.
        return if @$r1 != @$r2;

        foreach my $item (@$r1) {
            # they are not equal if it can't find an element in r2
            # that is equal to $item. Notice ordering doesn't
            # matter.
            return unless grep { _are_equal($item, $_) } @$r2;
        }

        return 1;
    }
    elsif (ref $r1 eq 'SCALAR' and ref $r2 eq 'SCALAR') {
        return $$r1 eq $$r2;
    }
    elsif (ref $r1 eq 'HASH' and ref $r2 eq 'HASH') {
        # Hashes can't be equal unless their keys are equal.
        return unless ( %$r1 ~~ %$r2 );

        # Compare the equality of the values for each key.
        foreach my $key (keys %$r1) {
            return unless _are_equal( $r1->{$key}, $r2->{$key} );
        }

        return 1;
    }
    elsif ( !ref $r1 and !ref $r2 ) {
        return $r1 eq $r2;
    }
    else {
        # So this is ugly-land: objects (possibly overloaded) or mix
        # between objects, unblessed refs and non-refs
        return _equal_possibly_overloaded( $r1, $r2 );
    }
}

sub _equal_possibly_overloaded {
    my ($r1, $r2) = @_;

    require overload;
    require Scalar::Util;

    my $is_ref_1 = ref $r1;
    my $is_ref_2 = ref $r2;

    my $is_obj_1 = $is_ref_1 ? Scalar::Util::blessed($r1) : 0;
    my $is_obj_2 = $is_ref_2 ? Scalar::Util::blessed($r2) : 0;

    # Return early for the most common case: two unblessed refs
    # of different reftype (ie, HASH vs ARRAY).

    return if !$is_obj_1 and !$is_obj_2;

    my $is_ol_1 = $is_obj_1 ? overload::Overloaded($r1) : 0;
    my $is_ol_2 = $is_obj_2 ? overload::Overloaded($r2) : 0;

    if ( $is_ref_1 and $is_ref_2 ) {
        if ( !$is_ol_1 and !$is_ol_2 ) {
            return $r1 eq $r2;
        }
        elsif ( $is_ol_1 and !$is_ol_2 ) {
            return _equal_one_overloaded( $r2, $r1 );
        }
        elsif ( !$is_ol_1 and $is_ol_2 ) {
            return _equal_one_overloaded( $r1, $r2 );
        }
        else {
            return _equal_both_overloaded( $r1, $r2 );
        }
    }
    elsif ( $is_ref_1 and ! $is_ref_2 ) {
        if ( $is_ol_1 ) {
            return _equal_one_overloaded( $r2, $r1 );
        }
        else {
            return;
        }
    }
    elsif ( !$is_ref_1 and $is_ref_2 ) {
        if ( $is_ol_2 ) {
            return _equal_one_overloaded( $r1, $r2 );
        }
        else {
            return;
        }
    }
    else {
        return;
    }
}

sub _equal_one_overloaded {
    my ($non_ol, $overloaded) = @_;

    require Scalar::Util;

    if ( overload::Method($overloaded, '==') and Scalar::Util::looks_like_number($non_ol) ) {
        return $non_ol == $overloaded;
    }
    elsif ( overload::Method($overloaded, 'eq') ) {
        return $non_ol eq $overloaded;
    }
    else {
        return;
    }
}

sub _equal_both_overloaded {
    my ($r1, $r2) = @_;

    # Both are overloaded

    if ( overload::Method($r1, '==') and overload::Method($r2, '==') ) {
        return $r1 == $r2;
    }

    elsif ( overload::Method($r1, 'eq') and overload::Method($r2, 'eq') ) {
        return $r1 eq $r2;
    }
    else {
        return;
    }
}

1;
