#!perl

use Test::More 'no_plan';
use perl5i::latest;

is CLASS, __PACKAGE__, "CLASS keyword";
is $CLASS, __PACKAGE__, '$CLASS';
