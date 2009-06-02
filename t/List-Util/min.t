#!perl

use perl5i;

use Test::More tests => 4;

my $v;

$v = [ (9) ]->min;
is( $v, 9, 'single arg' );

$v = [ 1, 2 ]->min;
is( $v, 1, '2-arg ordered' );

$v = [ ( 2, 1 ) ]->min;
is( $v, 1, '2-arg reverse ordered' );

my @a = map  { rand() } 1 .. 20;
my @b = sort { $a <=> $b } @a;
$v = [ (@a) ]->min;
is( $v, $b[0], '20-arg random order' );
