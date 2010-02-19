#!/usr/bin/perl

# Test that perl5i makes @ARGV utf8

BEGIN {
    @ARGV = qw(føø bar bāz);
}

use perl5i::latest;
use Test::More;

is_deeply \@ARGV, [qw(føø bar bāz)];

done_testing();
