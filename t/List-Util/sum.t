#!perl

use perl5i;

use Test::More tests => 6;

my $v = []->sum;
is( $v, undef, 'no args' );

$v = [ (9) ]->sum;
is( $v, 9, 'one arg' );

$v = [ ( 1, 2, 3, 4 ) ]->sum;
is( $v, 10, '4 args' );

$v = [ (-1) ]->sum;
is( $v, -1, 'one -1' );

my $x = -3;

$v = [ ( $x, 3 ) ]->sum;
is( $v, 0, 'variable arg' );

$v = [ ( -3.5, 3 ) ]->sum;
is( $v, -0.5, 'real numbers' );

