#!/usr/bin/env perl

use perl5i::latest;

use lib 't/lib';
use Test::More;
use Test::perl5i;

my @a = ( 0 .. 5 );
my @b = ( 3 .. 8 );
my $i;

is_deeply( $i = @a->intersect(\@b), [ 3, 4, 5 ], 'Simple number intersect' );
is_deeply( $i = @b->intersect(\@a), [ 3, 4, 5 ], 'Simple number intersect' );

my @i = @b->intersect(\@a);

is scalar @i, 3, "Returns an array in list context";

# No arguments
is_deeply( $i = @a->intersect, \@a, 'No arguments' );

# Empty array
is_deeply( $i = @a->intersect([]), [], 'Intersect with an empty array');

is_deeply( $i = []->diff, [], 'Diff an empty array' );

# Dies when called with non-arrayref arguments

throws_ok { @a->intersect('foo')        } qr/Arguments must be/;
throws_ok { @a->intersect({ foo => 1 }) } qr/Arguments must be/;
throws_ok { []->intersect(\'foo')       } qr/Arguments must be/;
throws_ok { @a->intersect(undef, \@a)   } qr/Arguments must be/;

# Works with strings also
is_deeply( $i = [qw(foo bar)]->intersect(['bar']), ['bar'], 'Works ok with strings' );

# Mix strings and numbers
is_deeply( $i = [qw(foo bar)]->intersect(\@a), [], 'Mix strings and numbers' );

# Mix numbers and strings
is_deeply( $i = @a->intersect([qw(foo bar)]), [], 'Mix numbers and strings' );

# Ordering shouldn't matter in the top level array
is_deeply( $i = [ 1, 2 ]->intersect([ 2, 1 ]), [ 1, 2, ] );

# ... but it matters for there down ( see [ github 96 ] )
is_deeply( $i = [ [ 1, 2 ] ]->intersect([ [ 2, 1 ] ]), [ ] );

# Diff more than two arrays
is_deeply( $i = @a->intersect(\@b, [ 4, 'foo' ] ), [ 4 ],    'Intersect more than two arrays' );
is_deeply( $i = @a->intersect(\@b, [ 3, 5, 12 ] ), [ 3, 5 ], 'Intersect more than two arrays' );

is_deeply(
    $i = [ { foo => 1 }, { foo => \2 } ]->intersect( [ { foo => \2 } ] ),
    [ { foo => \2 } ],
    'Works for nested data structures',
);

# Test undef
{
    my @array = (1,2,undef,4);
    is_deeply( $i = @array->intersect([1,2,4,undef]), [ 1, 2, undef, 4 ] );
    is_deeply( $i = @array->intersect([1,2,4]), [ 1, 2, 4 ] );
}

# Test REF
{
    my $ref1 = \42;
    my $ref2 = \42;
    my @array = (1,2,\$ref1,4);
    is_deeply( $i = @array->intersect([4,\$ref2,2,1]), \@array );

    my $ref3 = \23;
    is_deeply( $i = @array->intersect([1,2,\$ref3,4]), [1, 2, 4] );
}

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
        qw( foo bar baz ),
        { foo => { foo => $code } }
    ],
    [ qw( foo baz ), \'gorch' ]     # this is unique to $bar
];

is_deeply(
    $i = $foo->intersect($bar),
    [ 'foo', 'baz', [ qw(foo bar baz), { foo => { foo => $code } } ] ],
    "stress test 1"
);
is_deeply(
    $i = $bar->intersect($foo),
    [ 'foo', 'baz', [ qw(foo bar baz), { foo => { foo => $code } } ] ],
    "stress test 2"
);

is_deeply( $i = [ $code ]->intersect([ sub { 'bar' }]), [ ] );
is_deeply( $i = [ $code ]->intersect([ $code ]), [ $code ] );

# Test overloading
{
    package Number;
    use overload
        '0+' => sub { 42 },
        fallback => 1;

    sub new { bless {} }
}

{
    package String;
    use overload
        '""' => sub { 'foo' },
        fallback => 1;

    sub new { bless {} }
}

my $answer = Number->new;
my $string = String->new;

# Minimal testing of overloaded classes
ok( $answer == 42 );
ok( $string eq 'foo' );

is_deeply( $i = [ $answer, $string ]->intersect([ 'foo', 42 ]), [ $answer, $string ] );

# Overloaded objects vs. scalars
is_deeply( $i = [ $answer, $string ]->intersect([  'foo'  ]), [ $string ] );
is_deeply( $i = [ $answer, $string ]->intersect([   42    ]), [ $answer ] );
is_deeply( $i = [ 42,      'foo'   ]->intersect([ $answer ]), [   42    ] );
is_deeply( $i = [ 42,      'foo'   ]->intersect([ $string ]), [  'foo'  ] );

# Overloaded objects vs. overloaded objects.
is_deeply( $i = [ $answer, $string ]->diff([ $string ]), [ $answer ] );
is_deeply( $i = [ $answer, $string ]->diff([ $answer ]), [ $string ] );
is_deeply( $i = [ $answer, $string ]->diff([ $answer ]), [  'foo'  ] );


# Objects vs. objects
my $object = bless {}, 'Object';

is_deeply( $i = [ $object ]->intersect( [ $object ]), [ $object ] );

# Overloaded objects vs. non-overloaded objects
is_deeply( $i = [ $object ]->intersect( [ $answer ] ), [ ] );
is_deeply( $i = [ $answer ]->intersect( [ $object ] ), [ ] );

done_testing();
