#!/usr/bin/perl

# perl5i turns on utf8

use PerlIO;
use perl5i::latest;
use Test::More;

is "perl5i is MËTÁŁ"->length, 15;

# Test the standard handles and all newly opened handles are utf8
ok open my $test_fh, ">", "perlio_test";
END { unlink "perlio_test" }
for my $fh (*STDOUT, *STDIN, *STDERR, $test_fh) {
    my @layers = PerlIO::get_layers($fh);
    ok(@layers->grep(qr/utf8/)->flatten) or diag explain { $fh => \@layers };
}

done_testing;
