#!/usr/bin/perl

# perl5i turns on utf8

use strict;
use warnings;

use PerlIO;
use Test::More;


# Test with it on
{
    use perl5i::latest;

    is "perl5i is MËTÁŁ"->length, 15;

    # Test the standard handles and all newly opened handles are utf8
    ok open my $test_fh, ">", "perlio_test";
    END { unlink "perlio_test" }
    for my $fh (*STDOUT, *STDIN, *STDERR, $test_fh) {
        my @layers = PerlIO::get_layers($fh);
        ok(@layers->grep(qr/utf8/)->flatten) or diag explain { $fh => \@layers };
    }
}


# And off
{
    ok open my $test_fh, ">", "perlio_test2";
    END { unlink "perlio_test2" }

    my @layers = PerlIO::get_layers($test_fh);
    ok( !grep /utf8/, @layers ) or diag explain { $test_fh => \@layers };
}

done_testing;
