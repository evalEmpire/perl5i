#!/usr/bin/perl -w

use perl5i;
use Test::More tests => 3;
use Data::Dumper;

my @a = (1 .. 10);

is [@a]->perl, Dumper [@a];

is @a->perl, Dumper \@a;

my $ref = \@a;

is $ref->perl, Dumper $ref;
