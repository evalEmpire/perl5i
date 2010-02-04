#!/usr/bin/perl -w

# Methods were leaking into the SCALAR package from loaded modules

use perl5i::latest;
use Test::More;

ok( !SCALAR->can("croak") );

done_testing();
