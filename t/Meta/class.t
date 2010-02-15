#!/usr/bin/perl

# Test Meta->class

use strict;
use warnings;

use perl5i::latest;

use Test::More;

my $obj = bless {}, "Foo";
is $obj->mo->class, "Foo";

is 42->mo->class, 42;

my @array;
is @array->mo->class, "ARRAY";

my %hash;
is %hash->mo->class, "HASH";

my $ref = \42;
is $ref->mo->class, "SCALAR";

is []->mo->class, "ARRAY";

is {}->mo->class, "HASH";

done_testing();
