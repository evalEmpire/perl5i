#!/usr/bin/perl

use perl5i;
use Test::More 'no_plan';

{
    my $time = localtime;
    cmp_ok $time->year, ">", 1971;
}

{
    my $time = gmtime;
    cmp_ok $time->year, ">", 1971;
}
