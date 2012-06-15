# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2::ARRAY;
use 5.010;

use strict;
use warnings;

# Don't accidentally turn carp/croak into methods.
require Carp::Fix::1_25;

use perl5i::2::Signatures;
use perl5i::2::autobox;

# A foreach which honors the number of parameters in the signature
method foreach($code) {
    my $n = 1;
    if( my $sig = $code->signature ) {
        $n = $sig->num_positional_params;
        Carp::Fix::1_25::croak("Function passed to foreach takes no arguments") unless $n;
    }

    my $idx = 0;
    while ( $idx <= $#{$self} ) {
        $code->(@{$self}[$idx..($idx+$n-1)]);
        $idx += $n;
    }

    return;
}

method first($filter) {
    # Deep recursion and segfault (lines 90 and 91 in first.t) if we use
    # the same elegant approach as in grep().
    if ( ref $filter eq 'Regexp' ) {
        return List::Util::first( sub { $_ ~~ $filter }, @$self );
    }

    return List::Util::first( sub { $filter->() }, @$self );

}

method map( $code ) {
    my @result = CORE::map { $code->($_) } @$self;

    return wantarray ? @result : \@result;
}

method as_hash{
    my %result = CORE::map { $_ => 1 } @$self;
    return wantarray ? %result : \%result;
}


method pick ( $num ){
    Carp::Fix::1_25::croak("pick() takes the number of elements to pick")
      unless defined $num;
    Carp::Fix::1_25::croak("pick() takes a positive integer or zero, not '$num'")
      unless $num->is_integer && ($num->is_positive or $num == 0);
    
    if($num >= @$self){
        my @result = List::Util::shuffle(@$self);
        return wantarray ? @result : \@result;
    }
    
    # for the first position in the array, generate a random number that gives
    # that element an n/N chance of being picked (where n is the number of elements to pick and N is the total array size);
    # repeat for the rest of the array, each time altering the probability of
    # the element being picked to reflect the number of elements picked so far and the number left. 
    my $num_left = @$self;
    my @result;
    my $i=0;
    while($num > 0){
        my $rand = int(rand($num_left));
        if($rand < $num){
            push(@result, $self->[$i]);
            $num--;
        }
        $num_left--;
        $i++;
    }

    # Don't return the picks in the same order as the original array
    # Simulates what would happen if you shuffled first
    @result = @result->shuffle;

    return wantarray ? @result : \@result;
}


method pick_one() {
    return @$self[int rand @$self];
}


method grep($filter) {
    my @result = CORE::grep { $_ ~~ $filter } @$self;

    return wantarray ? @result : \@result;
}

method popn($times) {
    Carp::Fix::1_25::croak("popn() takes the number of elements to pop")
      unless defined $times;
    Carp::Fix::1_25::croak("popn() takes a positive integer or zero, not '$times'")
      unless $times->is_integer && ($times->is_positive or $times == 0);

    # splice() will choke if you walk off the array, so rein it in
    $times = scalar(@$self) if ($times > scalar(@$self));

    my @result = splice(@$self, -$times, $times);
    return wantarray ? @result : \@result;
}

method shiftn($times) {
    Carp::Fix::1_25::croak("shiftn() takes the number of elements to shift")
      unless defined $times;
    Carp::Fix::1_25::croak("shiftn() takes a positive integer or zero, not '$times'")
      unless $times->is_integer && ($times->is_positive or $times == 0);

    # splice() will choke if you walk off the array, so rein it in
    $times = scalar(@$self) if ($times > scalar(@$self));

    my @result = splice(@$self, 0, $times);
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

method diff(@rest) {
    unless (@rest) {
        return wantarray ? @$self : $self;
    }

    require List::MoreUtils;

    my $has_refs = List::MoreUtils::any(sub { ref $_ }, @$self);

    my $diff_two = $has_refs ? $diff_two_deeply : $diff_two_simply;

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $self = $diff_two->($self, $array);
    }

    return wantarray ? @$self : $self;
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

method intersect(@rest) {
    unless (@rest) {
        return wantarray ? @$self : $self;
    }

    require List::MoreUtils;
    my $has_refs = List::MoreUtils::any(sub { ref $_ }, @$self);

    my $intersect_two = $has_refs ? $intersect_two_deeply : $intersect_two_simply;

    # XXX If I use carp here, the exception is "bizarre copy of ARRAY in
    # ssasign ... "
    die "Arguments must be array references" if grep { ref $_ ne 'ARRAY' } @rest;

    foreach my $array (@rest) {
        $self = $intersect_two->($self, $array);
    }

    return wantarray ? @$self : $self;
}

method ltrim($charset) {
    my @result = CORE::map { $_->ltrim($charset) } @$self;

    return wantarray ? @result : \@result;
}

method rtrim($charset) {
    my @result = CORE::map { $_->rtrim($charset) } @$self;

    return wantarray ? @result : \@result;
}

method trim($charset) {
    my @result = CORE::map { $_->trim($charset) } @$self;

    return wantarray ? @result : \@result;
}


1;
