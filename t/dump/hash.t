#!perl -w

use perl5i::latest;
use Test::More tests => 3;

my %h = (
    a => 1,
    b => 2,
    c => 3
);
my $ref = \%h;

is_deeply eval( {%h}->perl ), {%h};

is_deeply eval %h->perl, \%h;

is_deeply eval $ref->perl, $ref;
