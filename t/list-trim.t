#!/usr/bin/env perl

use perl5i::latest;

use lib 't/lib';
use Test::More;
use Test::perl5i;

my @a = ( '   foo', 'bar   ', '   baz   ' );
my @b = ( '-->foo', 'bar<--', '-->baz<--' );

# Default option
is_deeply(
    scalar @a->ltrim,
    [ 'foo', 'bar   ', 'baz   ' ],
    'Left array trim'
);

is_deeply(
    scalar @a->rtrim,
    [ '   foo', 'bar', '   baz' ],
    'Right array trim'
);

is_deeply(
    scalar @a->trim,
    [ 'foo', 'bar', 'baz' ],
    'Array trim'
);

# Character set argument
is_deeply(
    scalar @b->ltrim('-><'),
    [ 'foo', 'bar<--', 'baz<--' ],
    'Left array trim with argument'
);

is_deeply(
    scalar @b->rtrim('-><'),
    [ '-->foo', 'bar', '-->baz' ],
    'Right array trim with argument'
);

is_deeply(
    scalar @b->trim('-><'),
    [ 'foo', 'bar', 'baz' ],
    'Array trim with argument'
);

# Literal array ref
is_deeply(
    scalar [ '   foo', 'bar   ', '   baz   ' ]->trim,
    [ 'foo', 'bar', 'baz' ],
    'Array ref trim'
);

# Chaining
is_deeply(
    scalar @a->ltrim->rtrim,
    [ 'foo', 'bar', 'baz' ],
    'Chained trim'
);

# Empty array
is_deeply( scalar []->trim, [], 'Empty array trim' );

# Context
is_deeply(
    [@a->trim],
    [ 'foo', 'bar', 'baz' ],
    'Array trim, list context'
);

is_deeply(
    [@a->ltrim],
    [ 'foo', 'bar   ', 'baz   ' ],
    'Left array trim, list context'
);

is_deeply(
    [@a->rtrim],
    [ '   foo', 'bar', '   baz' ],
    'Right array trim, list context'
);


done_testing();
