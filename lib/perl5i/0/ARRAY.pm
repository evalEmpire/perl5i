# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::ARRAY;
use 5.010;

use strict;
use warnings;
no if $] >= 5.018000, warnings => 'experimental::smartmatch';

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
    my @minmax = List::MoreUtils::minmax(@{$_[0]});
    return wantarray ? @minmax : \@minmax;
}

sub ARRAY::mesh {
    require List::MoreUtils;
    my @mesh = List::MoreUtils::zip(@_);
    return wantarray ? @mesh : \@mesh;
}


# Returns the code which will run when the object is used as a string
require overload;
my $overload_type = sub {
    return unless ref $_[0];
    my $str = overload::Method($_[0], q[""]);
    my $num = overload::Method($_[0], "0+");
    return "both" if $str and $num;
    return "" if !$str and !$num;
    return "str" if $str;
    return "num" if $num;
};


sub ARRAY::diff {
    my ($base, @rest) = @_;
    unless (@rest) {
        return wantarray ? @$base : $base;
    }

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = _diff_two($base, $array);
    }

    return wantarray ? @$base : $base;
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
            List::MoreUtils::any( sub { _are_equal( $item, $_ ) }, @$d )
        )
        {
            push @$diff, $item;
        }
    }

    return $diff;
}

sub ARRAY::intersect {
    my ($base, @rest) = @_;

    unless (@rest) {
        return wantarray ? @$base : $base;
    }

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = _intersect_two($base, $array);
    }

    return wantarray ? @$base : $base;
}

sub _intersect_two {
    # Compare differences between two arrays.
    my ($c, $d) = @_;

    my $intersect = [];

    # For each element of $c, try to find if it is equal to any of the
    # elements of $d. If it is, it's shared, and has to be pushed into
    # $intersect.

    require List::MoreUtils;
    foreach my $item (@$c) {
        if (
            List::MoreUtils::any( sub { _are_equal( $item, $_ ) }, @$d )
        )
        {
            push @$intersect, $item;
        }
    }

    return $intersect;
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

    # undef eq undef
    return 1 if !defined $r1 and !defined $r2;

    # One is defined, one isn't
    return   if defined $r1 xor defined $r2;

    my( $ref1, $ref2 ) = (ref $r1, ref $r2);

    if( !$ref1 and !$ref2 ) {
        my $is_num1 = SCALAR::is_number($r1);
        my $is_num2 = SCALAR::is_number($r2);
        if( $is_num1 xor $is_num2 ) {
            # One's looks like a number, the other doesn't.
            # Can't be equal.
            return 0;
        }
        elsif( $is_num1 ) {
            # They're both numbers
            return $r1 == $r2;
        }
        else {
            # They're both strings
            return $r1 eq $r2;
        }
    }
    elsif( $ref1 eq $ref2 ) {
        if ( $ref1 ~~ [qw(Regexp GLOB CODE)] ) {
            return $r1 eq $r2;
        }
        elsif ( $ref1 eq 'ARRAY' ) {
            return _equal_arrays( $r1, $r2 );
        }
        elsif ( $ref1 eq 'HASH' ) {
            return _equal_hashes( $r1, $r2 );
        }
        elsif ( $ref1 ~~ [qw(SCALAR REF)] ) {
            return _are_equal($$r1, $$r2);
        }
        else {
            # Must be an object
            return _equal_objects( $r1, $r2 );
        }
    }
    elsif( $ref1 and $ref2 ) {
        # They're both refs, but not of the same type
        my $is_overloaded1 = overload::Overloaded($r1);
        my $is_overloaded2 = overload::Overloaded($r2);

        if( $is_overloaded1 and $is_overloaded2 ) {
            # Two overloaded objects
            return _equal_overload( $r1, $r2 );  
        }
        else {
            # One's an overloaded object, the other is not  or
            # Two plain refs different type                 or
            # non-overloaded objects of different type.
            return 0;
        }
    }
    else {
        # One is a ref, one is not
        my $is_overloaded = $ref1 ? overload::Overloaded($r1)
                                  : overload::Overloaded($r2);

        if( $is_overloaded ) {
            # One's an overloaded object, one's a plain scalar
            return $ref1 ? _equal_overload_vs_scalar($r1, $r2)
                         : _equal_overload_vs_scalar($r2, $r1);
        }
        else {
            # One's a plain ref or object, one's a plain scalar
            return 0;
        }
    }
}


# Two objects, same class
sub _equal_objects {
    my($r1, $r2) = @_;

    # No need to check both, they're the same class
    my $is_overloaded = overload::Overloaded($r1);

    if( !$is_overloaded ) {
        # Neither are overloaded, they're the same class, are they the same object?
        return $r1 eq $r2;
    }
    else {
        return _equal_overload( $r1, $r2 );
    }
}


# Two objects, possibly different classes, both overloaded.
sub _equal_overload {
    my($obj1, $obj2) = @_;

    my $type1 = $overload_type->($obj1);
    my $type2 = $overload_type->($obj2);

    # One of them is not overloaded
    return if !$type1 or !$type2;

    if( $type1 eq 'both' and $type2 eq 'both' ) {
        return $obj1 == $obj2 || $obj1 eq $obj2;
    }
    elsif(
        ($type1 eq 'num' and $type2 eq 'str') or
        ($type1 eq 'str' and $type2 eq 'num')
    )
    {
        # They're not both numbers, not both strings, and not both both
        # Must be str vs num.
        return $type1 eq 'num' ? $obj1+0 eq "$obj2"
                               : $obj2+0 eq "$obj1";
    }
    elsif( 'num' ~~ [$type1, $type2] ) {
        return $obj1 == $obj2;
    }
    elsif( 'str' ~~ [$type1, $type2] ) {
        return $obj1 eq $obj2;
    }
    else {
        die "Should never be reached";
    }
}


# One overloaded object, one plain scalar
# STRING != OBJ
# NUMBER != OBJ
# STRING eq OBJeq
# STRING eq OBJboth
# STRING != OBJ== (using == will throw a  warning)
# NUMBER == OBJ==
# NUMBER eq OBJeq
# NUMBER == OBJboth
sub _equal_overload_vs_scalar {
    my($obj, $scalar) = @_;

    my $type = $overload_type->($obj);
    return unless $type;

    if( SCALAR::is_number($scalar) ) {
        if( $type eq 'str' ) {
            $obj eq $scalar;
        }
        else {
            $obj == $scalar;
        }
    }
    else {
        if( $type eq 'num' ) {
            # Can't reliably compare 
            return;
        }
        else {
            $obj eq $scalar;
        }
    }
}

sub _equal_arrays {
    my ($r1, $r2) = @_;
    # They can only be equal if they have the same nº of elements.
    return if @$r1 != @$r2;

    foreach my $i (0 .. @$r1 - 1) {
        return unless _are_equal($r1->[$i], $r2->[$i]);
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

1;
