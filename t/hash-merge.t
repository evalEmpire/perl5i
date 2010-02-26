#!/usr/bin/env perl
use Test::More;
use perl5i::latest;

my $a = { a => 1 };
my $b = { a => 100, b => 2 };
my $m;

is_deeply( $m = $a->merge($b), { a => 100, b => 2 } );

is_deeply( $m = $b->merge($a), { a => 1, b => 2 }, "Rightmost precedence" );

is_deeply( $m = $a->merge( $b, { a => 0 } ), { a => 0, b => 2 }, "Three arguments" );

is_deeply(
    $m = { 100 => { 1 => 2 } }->merge( { 100 => 'foo' } ),
    { 100 => 'foo' },
    'Works for nested hashes also'
);
my %merged = $a->merge($b);

is_deeply( \%merged, { a => 100, b => 2 }, "Returns hash in list context" );

done_testing;
