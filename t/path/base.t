#!/usr/bin/env perl

# Basic testing of path() and Path::Tiny

use perl5i::latest;
use Test::Most;

note "is Path::Tiny working?"; {
    my $file = $0->path;
    isa_ok $file, "Path::Tiny";

    my $content = $file->slurp;
    like $content, qr/slurp/;

    ok $file->exists;
}

done_testing;
