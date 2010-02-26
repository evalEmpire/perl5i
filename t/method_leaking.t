#!/usr/bin/perl -w

# Test methods and functions aren't leaking.

use perl5i::latest;
use Test::More;

ok( !SCALAR->can("croak") );
ok !defined &main::alias;

done_testing();
