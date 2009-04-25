#!/usr/bin/perl -w

use perl5i;
use Test::More tests => 3;
use Data::Dumper;

my %h = (
	a => 1,
	b => 2,
	c => 3
);

is {%h}->perl, Dumper {%h};

is %h->perl, Dumper \%h;

my $ref = \%h;

is $ref->perl, Dumper $ref;
