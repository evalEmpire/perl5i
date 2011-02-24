#!/usr/bin/perl

# Test that perl5i doesn't double encode @ARGV [github 176]

BEGIN {
    @ARGV = qw(føø bar bāz);
}

{
    package Foo;
    use perl5i::latest;
}

use perl5i::latest;
use Test::More;

is_deeply \@ARGV, [qw(føø bar bāz)];

done_testing();
