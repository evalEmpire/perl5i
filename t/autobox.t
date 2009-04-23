#!/usr/bin/perl -w

use perl5i;
use Test::More 'no_plan';

my @array = (1,2,3);
is @array->pop, 3;

sub SCALAR::my_strip {
    $_[0] =~ s/^\s+//;
    $_[0] =~ s/\s+$//;
}

my $string = "  foo ";
$string->my_strip;
is $string, "foo";
