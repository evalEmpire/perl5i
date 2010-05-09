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
      opts => { separator => ".", grouping => 3 }
    },
    { have => 123456789,        want => "1,23,45,67,89",
      opts => { grouping => 2, separator => "," }
    },
    { have => 123456789,        want => "123456789",
      opts => { grouping => 0, separator => "," }
    },
    { have => "123456789.987",        want => "123.456.789,987",
      opts => { separator => ".", decimal_point => "," }
    },
    { have => "123456789",        want => "123.456.789",
      opts => { separator => ".", decimal_point => "," }
    },
    # Preserve the trailing dot
    { have => "123456789.",        want => "123.456.789,",
      opts => { separator => ".", decimal_point => "," }
    },
    { have => "123456789.0",        want => "123.456.789,0",
      opts => { separator => ".", decimal_point => "," }
    },
    { have => 12345.678,        want => "12,345.678" },
    { have => 0,                want => "0" },
    { have => 0.12,             want => "0.12" },
);


for my $test (@tests) {
    my $have = $test->{have};
    my $want = $test->{want};
    my $opts = $test->{opts} || {};

    # Format and flatten the options
    my $opts_string = $opts->mo->perl;
    $opts_string =~ s/\n/ /g;
    $opts_string =~ s/^\s*{//;
    $opts_string =~ s/}\s*$//;

    is $have->commify($opts),          $want, "$have->commify($opts_string)";
}


done_testing();
