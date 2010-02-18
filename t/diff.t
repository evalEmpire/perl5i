#!/usr/bin/env perl
use Test::More;
use perl5i::latest;

my @a = ( 0 .. 5 );
my @b = ( 3 .. 8 );

is_deeply( @a->diff(\@b), [ 0, 1, 2 ] );

is_deeply( @b->diff(\@a), [ 6, 7, 8 ] );

# No arguments
is_deeply( @a->diff, \@a );

# Empty array
is_deeply( @a->diff([]), \@a);

is_deeply( []->diff, [] );

# Works with strings also
is_deeply( [qw(foo bar)]->diff(['bar']), ['foo'] );
is_deeply( [qw(foo bar)]->diff(\@a), [qw(foo bar)] );

is_deeply( @a->diff([qw(foo bar)]), \@a );


done_testing();
