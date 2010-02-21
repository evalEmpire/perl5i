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
throws_ok { @a->diff(undef, \@a)   } qr/Arguments must be/;

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
    [ { foo => 1 }, { foo => \2 } ]->diff( [ { foo => \2 } ] ),
    [ { foo => 1 } ],
    'Works for nested data structures',
);

# Stress test deep comparison

my $code = sub { 'foo' };

my $foo = [
    qw( foo bar baz ),              # plain elements
    { foo => 2 },                   # hash reference
    { bar => 1 },                   # hash reference
    [                               # array reference of ...
        qw( foo bar baz ),          # plain elements and ...
        { foo => { foo => $code } } # hash reference with hash ref as value
    ]                               # with code ref as value
];

my $bar = [
    qw( foo baz ),                  # bar is missing
    { foo => 1 },                   # 1 != 2, bar =! foo
    [                               # this arrayref is identical
        qw( foo baz bar ),
        { foo => { foo => $code } }
    ],
    [ qw( foo baz ), \'gorch' ]     # this is unique to $bar
];

is_deeply( $foo->diff($bar), [ 'bar', { foo => 2 }, { bar => 1 }     ], "stress test 1" );
is_deeply( $bar->diff($foo), [ { foo => 1 }, [qw(foo baz), \'gorch'] ], "stress test 2" );

is_deeply( [ $code ]->diff([ sub { 'bar' }]), [ $code ] );

# Test overloading
{
    package Number;
    use overload
        '==' => \&number_equal,
        '""' => sub { 42 };

    sub new { bless {} }

    sub number_equal {
        return 42 == $_[1];
    }
}

{
    package String;
    use overload
        'eq' => \&string_equal,
        '""' => sub { 'foo' };

    sub new { bless {} }

    sub string_equal {
        return 'foo' eq $_[1];
    }
}

my $answer = Number->new;
my $string = String->new;

# Minimal testing of overloaded classes
ok( $answer == 42 );
ok( $string eq 'foo' );

is_deeply( [ $answer, $string ]->diff([ 'foo', 42 ]), [] );

# Overloaded objects vs. scalars
is_deeply( [ $answer, $string ]->diff([  'foo'  ]), [ $answer ] );
is_deeply( [ $answer, $string ]->diff([  'foo'  ]), [   42    ] );
is_deeply( [ $answer, $string ]->diff([   42    ]), [ $string ] );
is_deeply( [ $answer, $string ]->diff([   42    ]), [  'foo'  ] );
is_deeply( [ 42,      'foo'   ]->diff([ $answer ]), [  'foo'  ] );
is_deeply( [ 42,      'foo'   ]->diff([ $string ]), [   42    ] );

# Overloaded objects vs. overloaded objects.
is_deeply( [ $answer, $string ]->diff([ $string ]), [ $answer ] );
is_deeply( [ $answer, $string ]->diff([ $string ]), [   42    ] );
is_deeply( [ $answer, $string ]->diff([ $answer ]), [ $string ] );
is_deeply( [ $answer, $string ]->diff([ $answer ]), [  'foo'  ] );

# Overloaded objects vs. non-overloaded objects

my $object = bless {}, 'Object';

is_deeply( [ $object ]->diff( [ $answer ] ), [ $object ] );
is_deeply( [ $answer ]->diff( [ $object ] ), [ $answer ] );

done_testing();
