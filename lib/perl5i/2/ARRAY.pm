# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2::ARRAY;
use 5.010;

use strict;
use warnings;

use Carp;

use perl5i::2::Signatures;
use perl5i::2::autobox;

# A foreach which honors the number of parameters in the signature
func foreach($array, $code) {
    my $n = 1;
    if( my $sig = $code->signature ) {
        $n = $sig->num_positional_params;
        croak "Function passed to foreach takes no arguments" unless $n;
    }

    my $idx = 0;
    do {
        $code->(@{$array}[$idx..($idx+$n-1)]);
        $idx += $n;
    } while $idx <= $#{$array};

    return;
}

func first($array, $filter) {
    # Deep recursion and segfault (lines 90 and 91 in first.t) if we use
    # the same elegant approach as in grep().
    if ( ref $filter eq 'Regexp' ) {
        return List::Util::first( sub { $_ ~~ $filter }, @$array );
    }

    return List::Util::first( sub { $filter->() }, @$array );

}

func map( $array, $code ) {
    my @result = CORE::map { $code->($_) } @$array;

    return wantarray ? @result : \@result;
}

func grep($array, $filter) {
    my @result = CORE::grep { $_ ~~ $filter } @$array;

    return wantarray ? @result : \@result;
}

sub all {
    require List::MoreUtils;
    return &List::MoreUtils::all($_[1], @{$_[0]});
}

sub any {
    require List::MoreUtils;
    return &List::MoreUtils::any($_[1], @{$_[0]});
}

sub none {
    require List::MoreUtils;
    return &List::MoreUtils::none($_[1], @{$_[0]});
}

sub true {
    require List::MoreUtils;
    return &List::MoreUtils::true($_[1], @{$_[0]});
}

sub false {
    require List::MoreUtils;
    return &List::MoreUtils::false($_[1], @{$_[0]});
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
    my @mesh = &List::MoreUtils::zip(@_);
    return wantarray ? @mesh : \@mesh;
}

# Compare differences between two arrays.
my $diff_two_deeply = func($c, $d) {
    my $diff = [];

    # For each element of $c, try to find if it is equal to any of the
    # elements of $d. If not, it's unique, and has to be pushed into
    # $diff.

    require perl5i::2::equal;
    require List::MoreUtils;
    foreach my $item (@$c) {
        unless (
            List::MoreUtils::any( sub { perl5i::2::equal::are_equal( $item, $_ ) }, @$d )
        )
        {
            push @$diff, $item;
        }
    }

    return $diff;
};

my $diff_two_simply = func($c, $d) {
    no warnings 'uninitialized';
    my %seen = map { $_ => 1 } @$d;

    my @diff = grep { not $seen{$_} } @$c;

    return \@diff;
};

func diff($base, @rest) {
    unless (@rest) {
        return wantarray ? @$base : $base;
    }

    require List::MoreUtils;

    my $has_refs = List::MoreUtils::any(sub { ref $_ }, @$base);

    my $diff_two = $has_refs ? $diff_two_deeply : $diff_two_simply;

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = $diff_two->($base, $array);
    }

    return wantarray ? @$base : $base;
}


my $intersect_two_simply = func($c, $d) {
    no warnings 'uninitialized';
    my %seen = map { $_ => 1 } @$d;

    my @intersect = grep { $seen{$_} } @$c;

    return \@intersect;
};

# Compare differences between two arrays.
my $intersect_two_deeply = func($c, $d) {
    require perl5i::2::equal;

    my $intersect = [];

    # For each element of $c, try to find if it is equal to any of the
    # elements of $d. If it is, it's shared, and has to be pushed into
    # $intersect.

    require List::MoreUtils;
    foreach my $item (@$c) {
        if (
            List::MoreUtils::any( sub { perl5i::2::equal::are_equal( $item, $_ ) }, @$d )
        )
        {
            push @$intersect, $item;
        }
    }

    return $intersect;
};

func intersect($base, @rest) {
    unless (@rest) {
        return wantarray ? @$base : $base;
    }

    require List::MoreUtils;
    my $has_refs = List::MoreUtils::any(sub { ref $_ }, @$base);

    my $intersect_two = $has_refs ? $intersect_two_deeply : $intersect_two_simply;

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $base = $intersect_two->($base, $array);
    }

    return wantarray ? @$base : $base;
}

func ltrim($array, $charset) {
    my @result = CORE::map { $_->ltrim($charset) } @$array;

    return wantarray ? @result : \@result;
}

func rtrim($array, $charset) {
    my @result = CORE::map { $_->rtrim($charset) } @$array;

    return wantarray ? @result : \@result;
}

func trim($array, $charset) {
    my @result = CORE::map { $_->trim($charset) } @$array;

    return wantarray ? @result : \@result;
}


1;
