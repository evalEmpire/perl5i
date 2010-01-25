#!/usr/bin/perl

use strict;
use warnings;

use perl5i;

use Test::More;

my $obj = bless {}, "Foo";
is $obj->reftype, "HASH";

is 42->reftype, undef;
is []->reftype, "ARRAY";

done_testing();
