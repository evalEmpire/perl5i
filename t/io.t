#!/usr/bin/perl -w

use perl5i;
use Test::More;

chdir 't';

"hello" > io("io-test");
END { unlink "io-test" }

is io("io-test")->slurp, "hello";

done_testing();
