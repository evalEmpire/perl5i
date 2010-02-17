#!perl

use perl5i::latest;
use Test::More 'no_plan';

my $stat = stat("MANIFEST");
isa_ok $stat, "File::stat";
cmp_ok $stat->size, ">", 0;

is_deeply [stat("MANIFEST")],  [CORE::stat("MANIFEST")],  'stat() in array context';
is_deeply [lstat("MANIFEST")], [CORE::lstat("MANIFEST")], 'lstat() in array context';
