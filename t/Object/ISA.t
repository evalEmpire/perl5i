#!/usr/bin/perl

use perl5i;
use Test::More;


# Test the basics
{
    is_deeply [Object->ISA], [];
    is_deeply [UNIVERSAL->ISA], ["Object"];
    is_deeply [DoesNotExist->ISA], [];
}

{
    package Parent;

    package Child;
    our @ISA = qw(Parent);
    sub new { bless {}, $_[0] }
}


# Single inheritance
{
    is_deeply [Child->ISA], ["Parent"];

    my $obj = Child->new;
    is_deeply [$obj->ISA], ["Parent"];
}


# Multiple inheritance
{
    package Foo;
    package Bar;
    package Baz;

    package Multiple;
    our @ISA = qw(Foo Bar Baz);
}

is_deeply [Multiple->ISA], [qw(Foo Bar Baz)];

done_testing();
