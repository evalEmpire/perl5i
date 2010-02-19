#!/usr/bin/env perl
use Test::More;
use perl5i::latest;

my @a = ( 0 .. 5 );
my @b = ( 3 .. 8 );

is_deeply( @a->diff(\@b), [ 0, 1, 2 ], 'Simple number diff' );

is_deeply( @b->diff(\@a), [ 6, 7, 8 ], 'Simple number diff' );

# No arguments
is_deeply( @a->diff, \@a, 'No arguments' );

# Empty array
is_deeply( @a->diff([]), \@a, 'Diff with an empty array');

is_deeply( []->diff, [], 'Diff an empty array' );

# Works with strings also
is_deeply( [qw(foo bar)]->diff(['bar']), ['foo'], 'Works ok with strings' );

# Mix strings and numbers
is_deeply( [qw(foo bar)]->diff(\@a), [qw(foo bar)], 'Mix strings and numbers' );

# Mix numbers and strings
is_deeply( @a->diff([qw(foo bar)]), \@a, 'Mix numbers and strings' );

is_deeply(
    [ { foo => 1 }, { foo => 2 } ]->diff( [ { foo => 2 } ] ),
    [ { foo => 1 } ],
    'Works for nested data structures',
);

done_testing();
