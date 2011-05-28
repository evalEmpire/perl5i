#!/usr/bin/env perl

use Test::More;

# using perl5i with a specific version is ok
eval "use perl5i version => 2";
ok !$@, "use perl5i version => ...";

done_testing();
