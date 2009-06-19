#!/usr/bin/perl

use perl5i;

use Test::More;

my $hello = 'hello';

is( center($hello, 7), ' hello ',
    'center() with even length has equal whitespace on both sides' );

is( center($hello, 8), '  hello ',
    'center() with odd length pads left' );

is( center($hello, 4), 'hello',
    'center() with too-short length returns the string unmodified' );

done_testing();
