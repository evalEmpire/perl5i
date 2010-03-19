#!/usr/bin/perl

use perl5i::latest;

use lib 't/lib';
use Test::More;
use Test::perl5i;
use Test::Warn;

warnings_like {
    carp("foo");
} qr/^foo/;

throws_ok {
    croak("bar");
} qr/^bar/;

done_testing();
