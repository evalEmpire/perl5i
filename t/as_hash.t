#!/usr/bin/perl

use perl5i::latest;
use Test::More;

note 'array to hash'; {
    my @array = qw(a b c);
    my %hash  = @array->as_hash;
    is_deeply \%hash, {a=>1, b=>1, c=>1};

    @array = (4, 3, 2, 1);
    my $hash = @array->as_hash;
    is_deeply $hash, {4=>1, 3=>1, 2=>1, 1=>1}; 
}

done_testing;
