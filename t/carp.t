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

eval { croak "wibble" };
like $@, qr/^wibble at @{[ __FILE__ ]} line @{[ __LINE__ - 1 ]}.\n/;

done_testing();
