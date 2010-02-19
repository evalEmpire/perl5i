#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );

is_deeply( @numbers->uniq, \@numbers );
is_deeply( [@numbers, @numbers]->uniq, \@numbers );

done_testing();
