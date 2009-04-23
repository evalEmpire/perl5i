#!/usr/bin/perl

use perl5i;
use Test::More "no_plan";

TODO: {
    local $TODO = "I don't know why autodie won't work in a wrapper";

    ok !eval { open my $fh, "hlaglaghlaghlagh"; 1 };
    ok !eval { system "haljlkjadlkjflajdf"; 1; };
}
