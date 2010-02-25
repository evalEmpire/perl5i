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


# Returns the code which will run when the object is used as a string
require overload;
my $treat_as_string = sub {
    return unless ref $_[0];
    return overload::Method($_[0], q[""]) || overload::Method($_[0], q[eq])
};

my $treat_as_number = sub {
    return unless ref $_[0];
    return overload::Method($_[0], q[0+]) || overload::Method($_[0], q[==]);
};

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

    # undef eq undef
    return 1 if !defined $r1 and !defined $r2;

    # One is defined, one isn't
    return   if defined $r1 xor defined $r2;

    my( $ref1, $ref2 ) = (ref $r1, ref $r2);

    my($cmp_as1, $cmp_as2);
    # Detect overloading.
    if( $ref1 ) {
        $cmp_as1 = $treat_as_number->($r1) ? 'number' :
                   $treat_as_string->($r1) ? 'string' :
                                             ""       ;
        $ref1 = '' if $cmp_as1;
    }
    else {
        $cmp_as1 = SCALAR::is_number($r1) ? 'number' : 'string';
    }

    if( $ref2 ) {
        $cmp_as2 = $treat_as_number->($r2) ? 'number' :
                   $treat_as_string->($r2) ? 'string' :
                                             ""       ;
        $ref2 = '' if $cmp_as2;
    }
    else {
        $cmp_as2 = SCALAR::is_number($r2) ? 'number' : 'string';
    }

    # Not the same ref type
    return if $ref1 ne $ref2;

    # One's a string, one's a number.  It'll never work
    return if $cmp_as1 ne $cmp_as2;

    # One has numeric overloading, honor that
    if ( $cmp_as1 eq 'number' ) {
        return $r1 == $r2;
    }
    elsif( $cmp_as1 eq 'string' ) {
        return $r1 eq $r2;
    }
    elsif ( $ref1 ~~ [qw(Regexp GLOB CODE)] ) {
        return $r1 eq $r2;
    }
    elsif ( $ref1 eq 'ARRAY' ) {
        return _equal_arrays( $r1, $r2 );
    }
    elsif ( $ref1 eq 'HASH' ) {
        return _equal_hashes( $r1, $r2 );
    }
    elsif ( $ref1 eq 'SCALAR' ) {
        return $$r1 eq $$r2;
    }
    elsif( $ref1 eq 'REF' ) {
        return _are_equal( $$r1, $$r2 );
    }
    elsif ( Scalar::Util::blessed($ref1) ) {
        # They're objects of the same class.  Don't violate encapsulation,
        # just see if they're the same object.
        return "$r1" eq "$r2";
    }
    else {
        die "Unknown ref type encountered in diff(): $ref1";
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
