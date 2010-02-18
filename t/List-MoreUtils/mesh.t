#!/usr/bin/env perl

use perl5i::latest;
use Test::More;

my @numbers = ( 1   ..  3  );
my @letters = ( 'a' .. 'c' );
my @words   = qw(foo bar baz);

is_deeply( @numbers->mesh(\@letters), [ 1, 'a', 2, 'b', 3, 'c' ] );

is_deeply(
    @numbers->mesh(\@letters, \@words),
    [ 1, 'a', 'foo', 2, 'b', 'bar', 3, 'c', 'baz' ],
);

done_testing();
