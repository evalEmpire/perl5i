#!/usr/bin/perl

use perl5i::latest;

use lib 't/lib';
use Test::More;
use Test::perl5i;

lives_ok {
    try {
        die "This should not die";
    } catch {
        "this worked";
    };
} 'Dying inside a try {} block is captured via Try::Tiny';

done_testing();
