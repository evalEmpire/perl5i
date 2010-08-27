#!/usr/bin/perl

use lib 't/lib';
use perl5i::latest;

use Test::More;

use_ok "ThisIsTrue";
is ThisIsTrue->bar, 42;

done_testing;
