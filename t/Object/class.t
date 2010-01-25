#!/usr/bin/perl

# Test Object->class

use strict;
use warnings;

use perl5i;

use Test::More;

my $obj = bless {}, "Foo";
is $obj->class, "Foo";

is 42->class, "SCALAR";

my @array;
is @array->class, "ARRAY";

my %hash;
is %hash->class, "HASH";

my $ref = \42;
is $ref->class, "SCALAR";

is []->class, "ARRAY";

is {}->class, "HASH";

done_testing();
