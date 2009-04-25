#!/usr/bin/perl -w

use perl5i;
use Test::More tests => 4;
use Data::Dumper;

my $str = "bar";
my $num = 100;

is "foo"->perl, Dumper "foo";

is 5->perl, Dumper 5;

is $str->perl, Dumper $str;

is $num->perl, Dumper $num;
