#!/usr/bin/perl

# This tests that a bug in indirect.pm which could cause a segfault does not
# come back.  See github 164 and rt.cpan.org 60378.

use perl5i::latest;
use Test::More;

eval {
    no warnings;
    my $x; my $y; "@{[ $x->$y ]}";
};
pass("Did not segfault");

done_testing(1);
