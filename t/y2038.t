#!/usr/bin/perl

use perl5i;
use Test::More 'no_plan';

TODO: {
    local $TODO = "Make Time::Piece and Time::y2038 play nice together";

    my $time = gmtime(2**35);
    is $time->year, 3058;
}

