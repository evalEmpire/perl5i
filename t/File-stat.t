#!/usr/bin/perl

use perl5i;
use Test::More 'no_plan';

my $stat = stat("MANIFEST");
isa_ok $stat, "File::stat";
cmp_ok $stat->size, ">", 0;
