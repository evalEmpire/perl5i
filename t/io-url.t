#!/usr/bin/perl -w

use perl5i::latest;
use Test::More;
use Test::Exception;

chdir 't';

# Test we can talk to a file URL
{
    "hello\nstuff\n" > io("io-url-test");
    ok -e "io-url-test";
    END { unlink "io-url-test" }

    is io->url("file://$CWD/io-url-test")->slurp, "hello\nstuff\n";
}


# Test that we normally won't try to open a URL
{
    throws_ok {
        io("http://www.google.com")->all;
    } qr{^Can't open file 'http://www.google.com' for input},
      "io() won't open a URL as a URL";
}


done_testing();

