#!perl -w

use perl5i::latest;
use Test::More tests => 3;

my @a   = ( 1 .. 10 );
my $ref = \@a;

is_deeply eval [@a]->mo->perl, [@a];

is_deeply eval @a->mo->perl, \@a;

is_deeply eval $ref->mo->perl, $ref;
