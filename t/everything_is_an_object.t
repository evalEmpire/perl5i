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

# autobox changed the way isa() works and now this fails
TODO: {
    local $TODO = '42->isa("UNIVERSAL") and autobox conflict, see [github #114]';
    ok 42->isa("UNIVERSAL"), "autoboxed things are objects";
}

done_testing();
