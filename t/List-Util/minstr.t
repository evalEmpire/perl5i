#!perl

use perl5i::latest;

use Test::More tests => 4;

my $v;

$v = [ ('a') ]->minstr;
is( $v, 'a', 'single arg' );

$v = [ ( 'a', 'b' ) ]->minstr;
is( $v, 'a', '2-arg ordered' );

$v = [ ( 'B', 'A' ) ]->minstr;
is( $v, 'A', '2-arg reverse ordered' );

my @a = map {
    pack( "u", pack( "C*", map { int( rand(256) ) } ( 0 .. int( rand(10) + 2 ) ) ) )
} 0 .. 20;
my @b = sort { $a cmp $b } @a;
$v = [ (@a) ]->minstr;
is( $v, $b[0], 'random ordered' );
