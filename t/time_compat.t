#!perl -w

# Test compatibility with Perl's time stuff.

use perl5i;

use Test::More 'no_plan';


#localtime in scalar context
like localtime(), qr{
  ^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)[ ]
  (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ]
  ([ \d]\d)\ (\d\d):(\d\d):(\d\d)\ (\d{4})$
}x;

my $beg = time();

SKIP: {
    # This conditional of "No tzset()" is stolen from ext/POSIX/t/time.t
    skip "No tzset()", 1
      if $^O eq "MacOS"
          || $^O eq "VMS"
          || $^O eq "cygwin"
          || $^O eq "djgpp"
          || $^O eq "MSWin32"
          || $^O eq "dos"
          || $^O eq "interix";

    # check that localtime respects changes to $ENV{TZ}
    $ENV{TZ} = "GMT-5";
    my( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime($beg);
    $ENV{TZ} = "GMT+5";
    ( $sec, $min, my $hour2, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime($beg);
    isnt( $hour, $hour2, 'changes to $ENV{TZ} respected' );
}


sleep 1;
my $now = time();

{
    my( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = gmtime($beg);
    my( $xsec, $foo ) = localtime($now);

    isnt( $sec, $xsec );
    ok $mday;
    ok $year;

    my $localyday = (localtime)[7];
    my $day_diff  = $localyday - $yday;
    ok(
        grep( { $day_diff == $_ } ( 0, 1, -1, 364, 365, -364, -365 ) ),
        'gmtime() and localtime() agree what day of year'
    );


    # This could be stricter.
    like(
        gmtime(), qr/^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)[ ]
                      (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ]
                      ([ \d]\d)\ (\d\d):(\d\d):(\d\d)\ (\d{4})$
                     /x,
        'gmtime(), scalar context'
    );
}

