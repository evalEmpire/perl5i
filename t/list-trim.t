#!/usr/bin/env perl

use perl5i::latest;

use lib 't/lib';
use Test::More;
use Test::perl5i;

my @a = ( '   foo', 'bar   ', '   baz   ' );
my @b = ( '-->foo', 'bar<--', '-->baz<--' );

my $d;

# Default option
is_deeply(
    $d = @a->ltrim,
    [ 'foo', 'bar   ', 'baz   ' ],
    'Left array trim'
);

is_deeply(
    $d = @a->rtrim,
    [ '   foo', 'bar', '   baz' ],
    'Right array trim'
);

is_deeply(
    $d = @a->trim,
    [ 'foo', 'bar', 'baz' ],
    'Array trim'
);

# Character set argument
is_deeply(
    $d = @b->ltrim('-><'),
    [ 'foo', 'bar<--', 'baz<--' ],
    'Left array trim with argument'
);

is_deeply(
    $d = @b->rtrim('-><'),
    [ '-->foo', 'bar', '-->baz' ],
    'Right array trim with argument'
);

is_deeply(
    $d = @b->trim('-><'),
    [ 'foo', 'bar', 'baz' ],
    'Array trim with argument'
);

# Literal array ref
is_deeply(
    $d = [ '   foo', 'bar   ', '   baz   ' ]->trim,
    [ 'foo', 'bar', 'baz' ],
    'Array ref trim'
);

# Chaining
is_deeply(
    $d = @a->ltrim->rtrim,
    [ 'foo', 'bar', 'baz' ],
    'Chained trim'
);

# Empty array
is_deeply( $d = []->trim, [], 'Empty array trim' );

# Context
my @d = @a->trim;
is( scalar @d, 3, 'Returns array in list context' );

done_testing();
