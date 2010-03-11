#!/usr/bin/perl

# Test Meta->class

use strict;
use warnings;

use perl5i::latest;

use Test::More;

my $obj = bless {}, "Foo";
is $obj->mc->class, "Foo";

is 42->mc->class, 42;

my @array;
is @array->mc->class, "ARRAY";

my %hash;
is %hash->mc->class, "HASH";

my $ref = \42;
is $ref->mc->class, "SCALAR";

is []->mc->class, "ARRAY";

is {}->mc->class, "HASH";

done_testing();
