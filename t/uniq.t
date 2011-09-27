#!/usr/bin/perl

use perl5i::latest;
use Test::More;

note "perl5ifaq entry"; {
    my %hash1 = (foo => 23, bar => 42, biff => 99);
    my %hash2 = (           bar => 99, biff => 42, yiff => 23);

    my @keys = (%hash1->keys, %hash2->keys);
    my @uniq = @keys->uniq;

    is_deeply scalar @uniq->sort, scalar [qw(foo bar biff yiff)]->sort;
}

done_testing;
