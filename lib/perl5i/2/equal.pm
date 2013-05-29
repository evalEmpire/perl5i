package perl5i::2::equal;

use strict;
no if $] >= 5.018000, warnings => 'experimental::smartmatch';

use perl5i::2::autobox;

sub are_equal {
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
        my $is_num1 = $r1->is_number;
        my $is_num2 = $r2->is_number;
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
            return are_equal($$r1, $$r2);
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

sub _equal_arrays {
    my ($r1, $r2) = @_;
    # They can only be equal if they have the same nº of elements.
    return if @$r1 != @$r2;

    foreach my $i (0 .. @$r1 - 1) {
        return unless are_equal($r1->[$i], $r2->[$i]);
    }

    return 1;
}

sub _equal_hashes {
    my ($r1, $r2) = @_;
    # Hashes can't be equal unless their keys are equal.
    return unless ( %$r1 ~~ %$r2 );

    # Compare the equality of the values for each key.
    foreach my $key (keys %$r1) {
        return unless are_equal( $r1->{$key}, $r2->{$key} );
    }

    return 1;
}

# Returns the code which will run when the object is used as a string
require overload;
sub _overload_type {
    return unless ref $_[0];
    my $str = overload::Method($_[0], q[""]);
    my $num = overload::Method($_[0], "0+");
    return "both" if $str and $num;
    return "" if !$str and !$num;
    return "str" if $str;
    return "num" if $num;
}

# Two objects, possibly different classes, both overloaded.
sub _equal_overload {
    my($obj1, $obj2) = @_;

    my $type1 = _overload_type($obj1);
    my $type2 = _overload_type($obj2);

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

    my $type = _overload_type($obj);
    return unless $type;

    if( $scalar->is_number ) {
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

1;
