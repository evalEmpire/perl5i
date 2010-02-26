#!/usr/bin/env perl
use Test::More;
use Test::Exception;
use perl5i::latest;

my @a = ( 0 .. 5 );
my @b = ( 3 .. 8 );

my $d;

is_deeply( $d = @a->diff(\@b), [ 0, 1, 2 ], 'Simple number diff' );
is_deeply( $d = @b->diff(\@a), [ 6, 7, 8 ], 'Simple number diff' );

# No arguments
is_deeply( $d = @a->diff, \@a, 'No arguments' );

# Empty array
is_deeply( $d = @a->diff([]), \@a, 'Diff with an empty array');
is_deeply( $d = []->diff, [], 'Diff an empty array' );

# Context
my @d = @a->diff(\@b);
is scalar @d, 3, "Returns array in list context";

# Dies when called with non-arrayref arguments

throws_ok { @a->diff('foo')        } qr/Arguments must be/;
throws_ok { @a->diff({ foo => 1 }) } qr/Arguments must be/;
throws_ok { []->diff(\'foo')       } qr/Arguments must be/;
throws_ok { @a->diff(undef, \@a)   } qr/Arguments must be/;

# Works with strings also
is_deeply( $d = [qw(foo bar)]->diff(['bar']), ['foo'], 'Works ok with strings' );

# Mix strings and numbers
is_deeply( $d = [qw(foo bar)]->diff(\@a), [qw(foo bar)], 'Mix strings and numbers' );

# Mix numbers and strings
is_deeply( $d =  @a->diff([qw(foo bar)]), \@a, 'Mix numbers and strings' );

# Ordering shouldn't matter in the top level array
is_deeply( $d = [ 1, 2 ]->diff([ 2, 1 ]), [] );

# ... but it matters for there down ( see [ github 96 ] )
is_deeply( $d =  [ [ 1, 2 ] ]->diff([ [ 2, 1 ] ]), [ [ 1, 2 ] ] );

# Diff more than two arrays
is_deeply( $d = @a->diff(\@b, [ 'foo' ] ), [ 0, 1, 2 ], 'Diff more than two arrays' );
is_deeply( $d = @a->diff(\@b, [ 1, 2 ]  ), [ 0 ],       'Diff more than two arrays' );

is_deeply(
    $d = [ { foo => 1 }, { foo => \2 } ]->diff( [ { foo => \2 } ] ),
    [ { foo => 1 } ],
    'Works for nested data structures',
);

# Test undef
{
    my @array = (1,2,undef,4);
    is_deeply( $d = @array->diff([1,2,4,undef]), [] );
    is_deeply( $d = @array->diff([1,2,4]), [undef] );
}

# Test REF
{
    my $ref1 = \42;
    my $ref2 = \42;
    my @array = (1,2,\$ref1,4);
    is_deeply( $d = @array->diff([4,\$ref2,2,1]), [] );

    my $ref3 = \23;
    is_deeply( $d = @array->diff([1,2,\$ref3,4]), [\$ref1] );
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

is_deeply( $d = $foo->diff($bar), [ 'bar', { foo => 2 }, { bar => 1 }     ], "stress test 1" );
is_deeply( $d = $bar->diff($foo), [ { foo => 1 }, [qw(foo baz), \'gorch'] ], "stress test 2" );

is_deeply( $d = [ $code ]->diff([ sub { 'bar' }]), [ $code ] );

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

is_deeply( $d = [ $answer, $string ]->diff([ 'foo', 42 ]), [] );

# Overloaded objects vs. scalars
is_deeply( $d = [ $answer, $string ]->diff([  'foo'  ]), [ $answer ] );
is_deeply( $d = [ $answer, $string ]->diff([   42    ]), [ $string ] );
is_deeply( $d = [ $answer, $string ]->diff([   42    ]), [  'foo'  ] );
is_deeply( $d = [ 42,      'foo'   ]->diff([ $answer ]), [  'foo'  ] );
is_deeply( $d = [ 42,      'foo'   ]->diff([ $string ]), [   42    ] );

# Overloaded objects vs. overloaded objects.
is_deeply( $d = [ $answer, $string ]->diff([ $string ]), [ $answer ] );
is_deeply( $d = [ $answer, $string ]->diff([ $answer ]), [ $string ] );
is_deeply( $d = [ $answer, $string ]->diff([ $answer ]), [  'foo'  ] );


# Objects vs. objects
my $object = bless {}, 'Object';

is_deeply( $d = [ $object ]->diff( [ $object ] ), [ ] );
is_deeply( $d = [ $object ]->diff( [ ] ), [ $object ] );

# Overloaded objects vs. non-overloaded objects
is_deeply( $d = [ $object ]->diff( [ $answer ] ), [ $object ] );
is_deeply( $d = [ $answer ]->diff( [ $object ] ), [ $answer ] );

done_testing();
