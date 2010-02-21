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

    my $diff = [];

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
    # Warning: complex if-then-else decision tree ahead. It's ordered on
    # my perceived and anecdotical take on the frequency of occurrence
    # of each reftype: most popular on top, most rare on the bottom.
    # This way we return as early as possible.

    return if !defined $r1 or !defined $r2;

    my ($ref1, $ref2) = (ref $r1, ref $r2);

    if ( !$ref1 and !$ref2 ) {
        # plain scalars;
        return $r1 eq $r2;
    }
    elsif ( $ref1 eq 'ARRAY' ) {
        return _equal_array( $r1, $r2, $ref2 );
    }
    elsif ( $ref2 eq 'ARRAY' ) {
        return _equal_array( $r2, $r1, $ref1 );
    }
    elsif ( $ref1 eq 'HASH' ) {
        return _equal_hash( $r1, $r2, $ref2 );
    }
    elsif ( $ref2 eq 'HASH' ) {
        return _equal_hash( $r2, $r1, $ref1 );
    }
    elsif ( $ref1 eq 'SCALAR' ) {
        return _equal_scalar( $r1, $r2, $ref2 );
    }
    elsif ( $ref2 eq 'SCALAR' ) {
        return _equal_scalar( $r2, $r1, $ref1 );
    }
    elsif ( $ref1 ~~ /GLOB|CODE/ or $ref2 ~~ /GLOB|CODE/ ) {
        return $r1 eq $r2;
    }
    elsif ( $ref1 ) {
        # ref1 *has* to be an object
        return _equal_object( $r1, $r2, $ref2 );
    }
    else {
        # ref2 *has* to be an object
        return _equal_object( $r2, $r1, $ref1 );
    }
}

sub _equal_array {
    my ($r1, $r2, $ref2) = @_;
    if (!$ref2 or $ref2 ne 'ARRAY') {
        return;
    }
    else {
        return _equal_arrays( $r1, $r2 );
    }
}

sub _equal_hash {
    my ($r1, $r2, $ref2) = @_;
    if ( !$ref2 or $ref2 ne 'HASH' ) {
        return;
    }
    else {
        return _equal_hashes( $r1, $r2 );
    }
}

sub _equal_scalar {
    my ($r1, $r2, $ref2) = @_;
    if ( !$ref2 or $ref2 ne 'SCALAR' ) {
        return;
    }
    else {
        return $$r1 eq $$r2;
    }
}

sub _equal_arrays {
    my ($r1, $r2) = @_;
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

sub _equal_hashes {
    my ($r1, $r2) = @_;
    # Hashes can't be equal unless their keys are equal.
    return unless ( %$r1 ~~ %$r2 );

    # Compare the equality of the values for each key.
    foreach my $key (keys %$r1) {
        return unless _are_equal( $r1->{$key}, $r2->{$key} );
    }

    return 1;
}

sub _equal_object {
    my ($r1, $r2, $ref2) = @_;

    require overload;
    if (not overload::Overloaded($r1)) {
        return "$r1" eq "$r2";
    }
    else {
        if ( $ref2 ) {
            # Now both r1 and r2 are objects, and r1 is overloaded
            if (not overload::Overloaded($r2) ) {
                return;
            }
            else {
                # Now both objects are overloaded.
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
        }
        else {
            # Here r1 is an object, and r2 is a scalar
            require Scalar::Util;
            if ( overload::Method($r1, '==') and Scalar::Util::looks_like_number($r2) ) {
                return $r1 == $r2;
            }
            elsif ( overload::Method($r1, 'eq') ) {
                return $r1 eq $r2;
            }
            else {
                return;
            }
        }
    }
}

1;
