#!/usr/bin/perl

use perl5i::latest;

use Test::More;

my @tests = (
    { have => 1,                want => 1 },
    { have => 1234,             want => "1,234" },
    { have => 123456789,        want => "123,456,789" },
    { have => "123456789.1234", want => "123,456,789.1234" },
    { have => -12345,           want => "-12,345" },
    { have => 123456789,        want => "123.456.789",
      opts => { seperator => ".", grouping => 3 }
    },
    { have => 123456789,        want => "1,23,45,67,89",
      opts => { grouping => 2, separator => "," }
    },
    { have => 123456789,        want => "123456789",
      opts => { grouping => 0, separator => "," }
    },
);

my $default_opts = {
    seperator   => ",",
    grouping    => 3,
};

for my $test (@tests) {
    my $have = $test->{have};
    my $want = $test->{want};
    my $opts = $test->{opts} || {};

    # Format and flatten the options
    my $opts_string = $opts->mo->perl;
    $opts_string =~ s/\n/ /g;
    $opts_string =~ s/^\s*{//;
    $opts_string =~ s/}\s*$//;

    is $have->commify(%$opts),          $want, "$have->commify($opts_string)";
}


done_testing();
