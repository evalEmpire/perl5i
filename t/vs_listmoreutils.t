#!/usr/bin/perl

# perl5i was violating List::MoreUtils' prototypes and so would not
# load after it.

use List::MoreUtils;
use perl5i::latest;

use Test::More tests => 1;

pass("perl5i can load after List::MoreUtils");

1;
