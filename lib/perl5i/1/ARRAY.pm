# vi: set ts=4 sw=4 ht=4 et :
package perl5i::1::ARRAY;
use 5.010;

use strict;
use warnings;

use perl5i::1::autobox;

sub first {
    my ( $array, $filter ) = @_;

    # Deep recursion and segfault (lines 90 and 91 in first.t) if we use
    # the same elegant approach as in grep().
    if ( ref $filter eq 'Regexp' ) {
        return List::Util::first( sub { $_ ~~ $filter }, @$array );
    }

    return List::Util::first( sub { $filter->() }, @$array );

}

sub grep {
    my ( $array, $filter ) = @_;

    my @result = CORE::grep { $_ ~~ $filter } @$array;

    return wantarray ? @result : \@result;
}

sub all {
    require List::MoreUtils;
    return List::MoreUtils::all($_[1], @{$_[0]});
}

sub any {
    require List::MoreUtils;
    return List::MoreUtils::any($_[1], @{$_[0]});
}

sub none {
    require List::MoreUtils;
    return List::MoreUtils::none($_[1], @{$_[0]});
}

sub true {
    require List::MoreUtils;
    return List::MoreUtils::true($_[1], @{$_[0]});
}

sub false {
    require List::MoreUtils;
    return List::MoreUtils::false($_[1], @{$_[0]});
}

sub uniq {
    require List::MoreUtils;
    my @uniq = List::MoreUtils::uniq(@{$_[0]});
    return wantarray ? @uniq : \@uniq;
}

sub minmax {
    require List::MoreUtils;
    my @minmax = List::MoreUtils::minmax(@{$_[0]});
    return wantarray ? @minmax : \@minmax;
}

sub mesh {
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

my $are_equal;

# Two objects, possibly different classes, both overloaded.
my $equal_overload = sub {
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
};


# Two objects, same class
my $equal_objects = sub {
    my($r1, $r2) = @_;

    # No need to check both, they're the same class
    my $is_overloaded = overload::Overloaded($r1);

    if( !$is_overloaded ) {
        # Neither are overloaded, they're the same class, are they the same object?
        return $r1 eq $r2;
    }
    else {
        return $equal_overload->( $r1, $r2 );
    }
};


# One overloaded object, one plain scalar
# STRING != OBJ
# NUMBER != OBJ
# STRING eq OBJeq
# STRING eq OBJboth
# STRING != OBJ== (using == will throw a  warning)
# NUMBER == OBJ==
# NUMBER eq OBJeq
# NUMBER == OBJboth
my $equal_overload_vs_scalar = sub {
    my($obj, $scalar) = @_;

    my $type = $overload_type->($obj);
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
};

my $equal_arrays = sub {
    my ($r1, $r2) = @_;
    # They can only be equal if they have the same nº of elements.
    return if @$r1 != @$r2;

    foreach my $i (0 .. @$r1 - 1) {
        return unless $are_equal->($r1->[$i], $r2->[$i]);
    }

    return 1;
};

my $equal_hashes = sub {
    my ($r1, $r2) = @_;
    # Hashes can't be equal unless their keys are equal.
    return unless ( %$r1 ~~ %$r2 );

    # Compare the equality of the values for each key.
    foreach my $key (keys %$r1) {
        return unless $are_equal->( $r1->{$key}, $r2->{$key} );
    }

    return 1;
};


$are_equal = sub {
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
            return $equal_arrays->( $r1, $r2 );
        }
        elsif ( $ref1 eq 'HASH' ) {
            return $equal_hashes->( $r1, $r2 );
        }
        elsif ( $ref1 ~~ [qw(SCALAR REF)] ) {
            return $are_equal->($$r1, $$r2);
        }
        else {
            # Must be an object
            return $equal_objects->( $r1, $r2 );
        }
    }
    elsif( $ref1 and $ref2 ) {
        # They're both refs, but not of the same type
        my $is_overloaded1 = overload::Overloaded($r1);
        my $is_overloaded2 = overload::Overloaded($r2);

        if( $is_overloaded1 and $is_overloaded2 ) {
            # Two overloaded objects
            return $equal_overload->( $r1, $r2 );  
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
            return $ref1 ? $equal_overload_vs_scalar->($r1, $r2)
                         : $equal_overload_vs_scalar->($r2, $r1);
        }
        else {
            # One's a plain ref or object, one's a plain scalar
            return 0;
        }
    }
};


my $diff_two = sub {
    # Compare differences between two arrays.
    my ($c, $d) = @_;

    my $diff = [];

    # For each element of $c, try to find if it is equal to any of the
    # elements of $d. If not, it's unique, and has to be pushed into
    # $diff.

    require List::MoreUtils;
    foreach my $item (@$c) {
        unless (
            List::MoreUtils::any( sub { $are_equal->( $item, $_ ) }, @$d )
        )
        {
            push @$diff, $item;
        }
    }

    return $diff;
};


sub diff {
    my ($base, @rest) = @_;
    unless (@rest) {
        return wantarray ? @$base : $base;
    }

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = $diff_two->($base, $array);
    }

    return wantarray ? @$base : $base;
}


my $intersect_two = sub {
    # Compare differences between two arrays.
    my ($c, $d) = @_;

    my $intersect = [];

    # For each element of $c, try to find if it is equal to any of the
    # elements of $d. If it is, it's shared, and has to be pushed into
    # $intersect.

    require List::MoreUtils;
    foreach my $item (@$c) {
        if (
            List::MoreUtils::any( sub { $are_equal->( $item, $_ ) }, @$d )
        )
        {
            push @$intersect, $item;
        }
    }

    return $intersect;
};

sub intersect {
    my ($base, @rest) = @_;

    unless (@rest) {
        return wantarray ? @$base : $base;
    }

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = $intersect_two->($base, $array);
    }

    return wantarray ? @$base : $base;
}


1;
