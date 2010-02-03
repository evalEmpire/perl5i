#!/usr/bin/perl

use strict;
use warnings;

use perl5i::latest;

use Test::More;

{
    package Foo;
    sub bar {}
}

isa_ok "Foo", "UNIVERSAL";

ok 42->isa("UNIVERSAL"), "autoboxed things are objects";

done_testing();
