#!/usr/bin/perl

use strict;
use warnings;

use perl5i;

use Test::More;

{
    package Foo;
    sub bar {}
}

isa_ok "Foo", "UNIVERSAL";
isa_ok "Foo", "Object";

ok 42->isa("Object"), "autoboxed things are objects";

done_testing();
