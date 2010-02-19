#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );

ok( @numbers->all( sub { $_ < 100 } ) );
ok( not ( @numbers->all( sub { $_ > 100 } )  ) );

done_testing();
