#!/usr/bin/perl

use perl5i::latest;
use Test::More;


# Test the basics
{
    is_deeply [UNIVERSAL->mo->ISA], [];
    is_deeply [DoesNotExist->mo->ISA], [];
}

{
    package Parent;

    package Child;
    our @ISA = qw(Parent);
    sub new { bless {}, $_[0] }
}


# Single inheritance
{
    is_deeply [Child->mc->ISA], ["Parent"];

    my $obj = Child->new;
    is_deeply [$obj->mo->ISA], ["Parent"];
}


# Multiple inheritance
{
    package Foo;
    package Bar;
    package Baz;

    package Multiple;
    our @ISA = qw(Foo Bar Baz);
}

is_deeply [Multiple->mc->ISA], [qw(Foo Bar Baz)];

is_deeply scalar Multiple->mc->ISA, [qw(Foo Bar Baz)], "scalar context";

done_testing();
