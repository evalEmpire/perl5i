#!/usr/bin/perl
use perl5i::latest;
use Test::More;
use Test::Exception;

lives_ok {
    try {
        die "This should not die";
    } catch {
        "this worked";
    };
} 'Dying inside a try {} block is captured via Try::Tiny';

done_testing();
