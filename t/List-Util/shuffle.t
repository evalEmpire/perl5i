#!perl

use perl5i::latest;

use Test::More tests => 6;


my @r;

@r = []->shuffle;
ok( !@r, 'no args' );

@r = [9]->shuffle;
is( 0 + @r, 1, '1 in 1 out' );
is( $r[0],  9, 'one arg' );

my @in = 1 .. 100;
@r = @in->shuffle;
is( 0 + @r, 0 + @in, 'arg count' );

isnt( "@r", "@in", 'result different to args' );

my @s = sort { $a <=> $b } @r;
is( "@in", "@s", 'values' );
