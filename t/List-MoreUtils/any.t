#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );

ok( @numbers->any( sub { $_ < 5 } ) );
ok( not ( @numbers->any( sub { $_ > 100 } )  ) );

done_testing();
