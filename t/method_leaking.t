#!/usr/bin/perl -w

# Methods were leaking into the SCALAR package from loaded modules

use perl5i;
use Test::More;

ok( !SCALAR->can("load") );

done_testing();
