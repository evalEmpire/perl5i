#!perl

use perl5i::latest;
use Test::More "no_plan";

ok !eval { open my $fh, "hlaglaghlaghlagh"; 1 };
ok !eval { system "haljlkjadlkjflajdf"; 1; };
