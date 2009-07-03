#!/usr/bin/perl

use perl5i;

use Config;
use Test::More;

my $perl5i = "./bin/perl5i".$Config{_exe};

ok -e $perl5i, "perl5i command line wrapper was built";

ok system("$perl5i -e 1") == 0, "  and it runs";

is `$perl5i -e 'say "Hello"'`, "Hello\n", "Hello perl5i!";

done_testing(3);
