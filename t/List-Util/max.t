#!perl

use perl5i::latest;

use Test::More tests => 4;

my $v;

$v = [1]->max;
is( $v, 1, 'single arg' );

$v = [ 1, 2 ]->max;
is( $v, 2, '2-arg ordered' );

$v = [ 2, 1 ]->max;
is( $v, 2, '2-arg reverse ordered' );

my @a = map  { rand() } 1 .. 20;
my @b = sort { $a <=> $b } @a;
$v = @a->max;
is( $v, $b[-1], '20-arg random order' );
