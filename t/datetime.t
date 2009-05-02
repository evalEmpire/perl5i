use perl5i;

use Test::More tests => 8;

#stole some tests from the Perl test suite

#localtime in scalar context
#FIXME: do locales affect this?
ok localtime() =~ m{
	^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)[ ]
	(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ]
	([ \d]\d)\ (\d\d):(\d\d):(\d\d)\ (\d{4})$
}x;

my $beg = time();

SKIP: {
    # This conditional of "No tzset()" is stolen from ext/POSIX/t/time.t
    skip "No tzset()", 1
        if $^O eq "MacOS" || $^O eq "VMS" || $^O eq "cygwin" ||
           $^O eq "djgpp" || $^O eq "MSWin32" || $^O eq "dos" ||
           $^O eq "interix";

# check that localtime respects changes to $ENV{TZ}
$ENV{TZ} = "GMT-5";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($beg);
$ENV{TZ} = "GMT+5";
($sec,$min, my $hour2,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($beg);
ok($hour != $hour2,                             'changes to $ENV{TZ} respected');
}

my $does_gmtime = gmtime($beg);
sleep 1;
my $now = time();

SKIP: {
    skip "No gmtime()", 3 unless $does_gmtime;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($beg);
my ($xsec,$foo) = localtime($now);

ok($sec != $xsec && $mday && $year,             'gmtime() list context');

my $localyday = (localtime)[7];
my $day_diff   = $localyday - $yday;
ok( grep({ $day_diff == $_ } (0, 1, -1, 364, 365, -364, -365)),
                     'gmtime() and localtime() agree what day of year');


# This could be stricter.
ok(gmtime() =~ /^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)[ ]
                 (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[ ]
                 ([ \d]\d)\ (\d\d):(\d\d):(\d\d)\ (\d{4})$
               /x,
   'gmtime(), scalar context'
  );
}

#test the object nature we are adding

my @methods1 = qw/sec min hour day month year day_of_week day_of_year is_dst/;
my @methods2 = qw/second minute hour mday mon year dow doy is_dst/;
my @methods3 = qw/sec min hour day_of_month mon year wday doy is_dst/;
my $obj      = gmtime();
my @date     = gmtime();

#adjust for object's niceties
$date[4]++;       #month is 1 - 12 not 0 - 11
$date[5] += 1900; #full year, not years since 1900
$date[7]++;       #julian is 1 .. 365|366 not 0 .. 354|355

for my $methods (\(@methods1, @methods2, @methods3)) {
	is_deeply [@date], [map { $obj->$_ } @$methods];
}
