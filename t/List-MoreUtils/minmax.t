#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );

is_deeply( @numbers->minmax, [1, 10] );
is_deeply( [@numbers, 20]->minmax, [1, 20] );

done_testing();
