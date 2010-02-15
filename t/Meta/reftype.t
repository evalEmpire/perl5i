#!/usr/bin/perl

use strict;
use warnings;

use perl5i::latest;

use Test::More;

my $obj = bless {}, "Foo";
is $obj->mo->reftype, "HASH";

is 42->mo->reftype, undef;
is []->mo->reftype, "ARRAY";
is sub {}->mo->reftype, "CODE";

TODO: {
    local $TODO = "bare hashes and arrays give the wrong reftype";

    my @array;
    is @array->mo->reftype, undef, "bare array";

    my %hash;
    is %hash->mo->reftype,  undef, "bare hash";
}

done_testing();
