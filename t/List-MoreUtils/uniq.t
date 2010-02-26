#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1 .. 10 );
my $u;

is_deeply( $u = @numbers->uniq, \@numbers );
is_deeply( $u = [@numbers, @numbers]->uniq, \@numbers );

my @u = @numbers->uniq;

is scalar @u, 10, "Returns an array in list context";

done_testing();
