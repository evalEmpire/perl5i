#!/usr/bin/perl

use Test::More;
use Test::Exception;
use perl5i::latest;

lives_ok {
    require Data::Dumper;
} "Require things that are installed works";

throws_ok {
    require Fake::Thing;
}
qr/Can't locate Fake\/Thing\.pm in your Perl library\./,
"Useful message";

push @INC => ".";

lives_ok {
    require Scalar::Util;
} "Require things that are installed works";

throws_ok {
    require Fake::Thing;
}
qr/Can't locate Fake\/Thing\.pm in your Perl library\./,
"Useful message";


done_testing;
