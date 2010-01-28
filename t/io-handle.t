#!/usr/bin/perl

use perl5i::latest;
use Test::More;

open my $fh, "<", $0;
ok eval { $fh->autoflush(1); 1; } or die $@;

done_testing();
