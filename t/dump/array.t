#!perl -w

use perl5i;
use Test::More tests => 3;

my @a   = ( 1 .. 10 );
my $ref = \@a;

is_deeply eval [@a]->perl, [@a];

is_deeply eval @a->perl, \@a;

is_deeply eval $ref->perl, $ref;
