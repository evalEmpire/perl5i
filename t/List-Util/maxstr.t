#!perl

use perl5i;

use Test::More tests => 4;

my $v;

$v = ['a']->maxstr;
is( $v, 'a', 'single arg' );

$v = [ 'a', 'b' ]->maxstr;
is( $v, 'b', '2-arg ordered' );

$v = [ 'B', 'A' ]->maxstr;
is( $v, 'B', '2-arg reverse ordered' );

my @a = map {
    pack( "u", pack( "C*", map { int( rand(256) ) } ( 0 .. int( rand(10) + 2 ) ) ) )
} 0 .. 20;
my @b = sort { $a cmp $b } @a;
$v = @a->maxstr;
is( $v, $b[-1], 'random ordered' );
