#!/usr/bin/perl -w

use strict;
use warnings;

use perl5i::latest;

use Test::More;

sub test_caller {
    my $caller = caller(0);
    my @want = CORE::caller(0);

    cmp_ok @want, ">=", 9, "CORE::caller() sane";
    is_deeply [caller(0)], \@want, "caller() in list context";

    # Perl6::Caller doesn't do hints or bitmask and that's fine by me.
    for my $key (qw(package filename line subroutine
                    hasargs wantarray evaltext is_require))
    {
        my $have = $caller->$key();
        my $want = shift @want;

        is $have, $want, "caller->$key";
    }

    is caller(), CORE::caller(), "stringified caller";
}

test_caller();

done_testing();
