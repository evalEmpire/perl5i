#!/usr/bin/perl

use perl5i::latest;
use Test::More;

# requiring perl5i is ok
require_ok "perl5i";

# using it is not
ok !eval "use perl5i";
like $@, qr/perl5i will break compatibility/;

done_testing();
