#!/usr/bin/perl

use perl5i;

use Test::More;
use Test::Warn;

my $hello = 'hello';

is( $hello->center(7), ' hello ',
    '->center() with even length has equal whitespace on both sides' );
is( $hello->center(7,'-'), '-hello-',
    '->center() with even length has equal whitespace on both sides' );

is( $hello->center(8), '  hello ',
    '->center() with odd length pads left' );

is( $hello->center(4), 'hello',
    '->center() with too-short length returns the string unmodified' );

is( $hello->center(0), 'hello',
    '->center(0)' );

is( $hello->center(-1), 'hello',
    '->center(-1)' );

warning_like {
    is( $hello->center(undef), 'hello',
        '->center(undef)' );
} qr/^Use of uninitialized value for size in center\(\) at $0 line /;

is( "even"->center(6, "-"), '-even-',
    '->center(6, "-")' );

is( "even"->center(7, "-"), '--even-',
    '->center(7, "-")' );

is( "even"->center(0, "-"), 'even',
    '->center(0, "-")' );

warning_like {
    is( $hello->center(10, "-=-"), '---hello--',
        '->center(undef)' );
} qr/^'-=-' is longer than one character, using '-' instead at $0 line /;

# Test that center() always returns the correct length
for my $size ($hello->length..20) {
    is( $hello->center($size)->length, $size, "center($size) returns that size" );
}

done_testing();
