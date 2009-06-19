#!/usr/bin/perl

use perl5i;

use Test::More;

my $hello = 'hello';

is( $hello->center(7), ' hello ',
    '->center() with even length has equal whitespace on both sides' );

is( $hello->center(8), '  hello ',
    '->center() with odd length pads left' );

is( $hello->center(4), 'hello',
    '->center() with too-short length returns the string unmodified' );

done_testing();
