#!/usr/bin/env perl
use Test::More;
use perl5i::latest;

my $a = { a => 1 };
my $b = { a => 100, b => 2 };

is_deeply( $a->merge($b), { a => 100, b => 2 } );

is_deeply( $b->merge($a), { a => 1, b => 2 }, "Rightmost precedence" );

is_deeply( $a->merge( $b, { a => 0 } ), { a => 0, b => 2 }, "Three arguments" );

is_deeply(
    { 100 => { 1 => 2 } }->merge( { 100 => 'foo' } ),
    { 100 => 'foo' },
    'Works for nested hashes also'
);

done_testing;
