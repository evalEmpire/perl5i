#!/usr/bin/perl

# Test the basic Modern::Perl functionality works.

use Test::More 'no_plan';
use Test::Warn;
use perl5i;

# strict?
{
    ok !eval '$foo = 42', "strict is on";
    like $@, qr/^Global symbol "\$foo" requires explicit package name/;
}


# warnings?
{
    my $foo;
    warning_like {
        $foo + 4;
    } qr/^Use of uninitialized value/;
}


# 5.10 features?
{
    my $thing = 42;
    given($thing) {
        when(42) {
            pass("given/when enabled");
        }
        default {
            fail("shouldn't reach here");
        }
    }
}


# C3?
{
    is mro::get_mro(__PACKAGE__), "c3", "C3 on";
}
