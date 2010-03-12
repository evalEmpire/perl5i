#!perl -w

# Test compatibility with Perl's time stuff.

use perl5i::latest;

use Test::More 'no_plan';
use Test::Output;


#localtime in scalar context
like localtime(), qr{
  ^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)[ ]
  (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ]
  ([ \d]\d)\ (\d\d):(\d\d):(\d\d)\ (\d{4})$
}x;

my $beg = time();

SKIP: {
    local $ENV{TZ};

    # Two time zones, different and likely to exist
    my $tz1 = "America/Los_Angeles";
    my $tz2 = "America/Chicago";

    # If the core localtime doesn't respond to TZ, we don't have to.
    skip "localtime does not respect TZ env", 1
      unless do {
          # check that localtime respects changes to $ENV{TZ}
          $ENV{TZ}  = $tz1;
          my $hour  = (CORE::localtime($beg))[2];
          $ENV{TZ}  = $tz2;
          my $hour2 = (CORE::localtime($beg))[2];
          $hour != $hour2;
      };

    # check that localtime respects changes to $ENV{TZ}
    $ENV{TZ}  = $tz1;
    my $hour  = (localtime($beg))[2];
    $ENV{TZ}  = $tz2;
    my $hour2 = (localtime($beg))[2];
    isnt $hour, $hour2, "localtime() honors TZ";
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


# Make sure the return from gmtime() compares as a string
{
    my $dt     = gmtime(123);
    my $string = CORE::gmtime(123);

    # Don't use is() or cmp_ok() as they can strip off overloading.
    # We want to explicitly check eq
    ok $dt eq $string, 'gmtime eq';
}


# Make sure time compares as a number
{
    my $dt     = time;
    my $num    = $dt+0;

    ok $dt == $num;
}


# Test times honor say and print
{
    # Due to a bug in 5.10's tie, the newline on say gets lost, but
    # it will be back in 5.12.  So we can't test for it.
    stdout_like { time->say;   } qr/^\d+$/;
    stdout_like { time->print; } qr/^\d+$/;

    my $time = int rand 2**31;
    my $date = gmtime($time);
    stdout_like { gmtime($time)->say;   } qr/^\Q$date\E$/;
    stdout_is   { gmtime($time)->print; } "$date";
}
