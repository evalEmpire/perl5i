#!perl -w

use perl5i;
use Test::More tests => 4;

my $str = "bar";
my $num = 0.1;

is eval "foo"->perl, "foo";

is eval 5->perl, 5;

is eval $str->perl, $str;

is eval $num->perl, $num;
