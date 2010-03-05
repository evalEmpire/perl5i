#!/usr/bin/perl

use perl5i::latest;
use Test::More;

my @array = (4,5,6);
is_deeply [@array->map(sub { $_[0] + 1 })],      [5,6,7], "map in list context";
is_deeply scalar @array->map(sub { $_[0] + 1 }), [5,6,7], "map in scalar context";

done_testing();
