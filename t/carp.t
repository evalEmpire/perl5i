#!/usr/bin/perl

use strict;
use warnings;

use perl5i::latest;

use Test::More;
use Test::Exception;
use Test::Warn;

warnings_like {
    carp("foo");
} qr/^foo/;

throws_ok {
    croak("bar");
} qr/^bar/;

done_testing();
