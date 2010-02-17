#!/usr/bin/perl

# perl5i turns on utf8

use perl5i::latest;
use Test::More;

is "perl5i is MËTÁŁ"->length, 15;

done_testing(1);
