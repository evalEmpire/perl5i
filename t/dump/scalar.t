#!perl -w

use perl5i::latest;
use Test::More tests => 4;

my $str = "bar";
my $num = 0.1;

is eval "foo"->mo->perl, "foo";

is eval 5->mo->perl, 5;

is eval $str->mo->perl, $str;

is eval $num->mo->perl, $num;
