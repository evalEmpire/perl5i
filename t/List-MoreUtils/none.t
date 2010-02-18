#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );

ok( @numbers->none( sub { $_ < 0 } ) );
ok( not @numbers->none( sub { $_ > 5 } ) );

done_testing();
