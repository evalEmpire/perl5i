#!/usr/bin/perl

use strict;
use warnings;

use perl5i;

use Test::More;

my $obj = bless {}, "Foo";
is $obj->reftype, "HASH";

is 42->reftype, undef;
is []->reftype, "ARRAY";
is sub {}->reftype, "CODE";

TODO: {
    local $TODO = "bare hashes and arrays give the wrong reftype";

    my @array;
    is @array->reftype, undef, "bare array";

    my %hash;
    is %hash->reftype,  undef, "bare hash";
}

done_testing();
