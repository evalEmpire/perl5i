#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );
my $m;

is_deeply( $m = @numbers->minmax, [1, 10] );
is_deeply( $m = [@numbers, 20]->minmax, [1, 20] );

my @m = @numbers->minmax;

is scalar @m, 2, "Returns an array in list context";

done_testing();
