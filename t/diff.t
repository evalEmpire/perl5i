#!/usr/bin/env perl
use Test::More;
use Test::Exception;
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

# Dies when called with non-arrayref arguments

throws_ok { @a->diff('foo')        } qr/Arguments must be/;
throws_ok { @a->diff({ foo => 1 }) } qr/Arguments must be/;
throws_ok { []->diff(\'foo')       } qr/Arguments must be/;

# Works with strings also
is_deeply( [qw(foo bar)]->diff(['bar']), ['foo'], 'Works ok with strings' );

# Mix strings and numbers
is_deeply( [qw(foo bar)]->diff(\@a), [qw(foo bar)], 'Mix strings and numbers' );

# Mix numbers and strings
is_deeply( @a->diff([qw(foo bar)]), \@a, 'Mix numbers and strings' );

# Diff more than two arrays
is_deeply( @a->diff(\@b, [ 'foo' ] ), [ 0, 1, 2 ], 'Diff more than two arrays' );
is_deeply( @a->diff(\@b, [ 1, 2 ]  ), [ 0 ],       'Diff more than two arrays' );

is_deeply(
    [ { foo => 1 }, { foo => 2 } ]->diff( [ { foo => 2 } ] ),
    [ { foo => 1 } ],
    'Works for nested data structures',
);

# Stress test deep comparison

my $foo = [
    qw( foo bar baz ),              # plain elements
    { foo => 2 },                   # hash reference
    [                               # array reference of ...
        qw( foo bar baz ),          # plain elements and ...
        { foo => { foo => 'bar' } } # hash reference with hash ref as value
    ]
];

my $bar = [
    qw( foo baz ),                  # bar is missing
    { foo => 1 },                   # 1 != 2
    [                               # this arrayref is identical
        qw( foo baz bar ),
        { foo => { foo => 'bar' } }
    ],
    [ qw( foo bar baz ) ]           # this is unique to $bar
];

is_deeply( $foo->diff($bar), [ 'bar', { foo => 2 } ],             "stress test 1" );
is_deeply( $bar->diff($foo), [ { foo => 1 }, [qw(foo bar baz)] ], "stress test 2" );

done_testing();
