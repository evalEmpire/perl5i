package perl5i::1::DateTime;

# A file to contain the Datetime work for perl5i to get it out of perl5i.pm

use 5.010;
use strict;
use warnings;

# Determine if we need Time::y2038 and only load if necessary.
# XXX This is a bit of a hack and should go into a config file.
use constant NEEDS_y2038 => (
    ((((CORE::gmtime(2**47-1))[5] || 0)      + 1900) != 4461763) ||
    ((((CORE::gmtime(-62135510400))[5] || 0) + 1900) != 1)
);

BEGIN {
    if( NEEDS_y2038 ) {
        require Time::y2038;
        Time::y2038->import;
    }
}


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_gmtime (;$) {
    my $time = @_ ? shift : time;
    return gmtime($time) if wantarray;

    my($sec, $min, $hour, $mday, $mon, $year) = gmtime($time);
    $mon++;
    $year += 1900;

    require DateTime;
    return perl5i::1::DateTime::y2038->new(
        year            => $year,
        month           => $mon,
        day             => $mday,
        hour            => $hour,
        minute          => $min,
        second          => $sec,
        formatter       => "perl5i::1::DateTime::Format::CTime"
    );
}


sub _get_datetime_timezone {
    state $local_tzfile = "/etc/localtime";

    # Always be sure to honor the TZ environment var
    return "local" if $ENV{TZ};

    # Work around a bug in DateTime::TimeZone on FreeBSD where it
    # can't determine the time zone if /etc/localtime is not a link.
    # Tzfile is also faster to do localtime calculations.
    if( -e $local_tzfile ) {
        # Could go through more effort to figure it out.  Meh.
        my $tzname = "Local";
        if( -l $local_tzfile ) {
            if( my $real_tzfile = eval { readlink $local_tzfile } ) {
                $tzname = $real_tzfile;
            }
        }
        require DateTime::TimeZone::Tzfile;
        my $tz = DateTime::TimeZone::Tzfile->new(
            name     => $tzname,
            filename => $local_tzfile
        );
        return $tz if $tz;
    }

    return "local";
}

## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_localtime (;$) {
    my $time = @_ ? shift : time;
    return localtime($time) if wantarray;

    my($sec, $min, $hour, $mday, $mon, $year) = localtime($time);
    $mon++;
    $year += 1900;

    state $tz = _get_datetime_timezone();

    require DateTime;
    return perl5i::1::DateTime::y2038->new(
        year            => $year,
        month           => $mon,
        day             => $mday,
        hour            => $hour,
        minute          => $min,
        second          => $sec,
        time_zone       => $tz,
        formatter       => "perl5i::1::DateTime::Format::CTime"
    );
}


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_time () {
    require DateTime::Format::Epoch;
    state $formatter = DateTime::Format::Epoch->new( epoch => DateTime->from_epoch( epoch => 0 ) );

    require DateTime;
    return perl5i::1::DateTime::time->from_epoch(
        epoch     => time,
        formatter => $formatter
    );
}


{
    package perl5i::1::DateTime::y2038;

    # Don't load DateTime until we need it.
    our @ISA = qw(DateTime);

    use overload
      "eq" => sub {
          my($dt1, $dt2) = @_;
          return "$dt1" eq "$dt2" if !eval { $dt2->isa("DateTime") };
          return $dt1 eq $dt2;
      };

    sub say {
        CORE::say("$_[0]");
    }

    sub print {
        CORE::print("$_[0]");
    }

    sub from_epoch {
        my $class = shift;

        if( perl5i::1::DateTime::NEEDS_y2038 ) {
            no warnings 'redefine';
            local *CORE::GLOBAL::gmtime    = \&Time::y2038::gmtime;
            local *CORE::GLOBAL::localtime = \&Time::y2038::localtime;

            return $class->SUPER::from_epoch(@_);
        }
        else {
            return $class->SUPER::from_epoch(@_);
        }
    }


    # Copy of DateTime's own epoch() function.
    if( perl5i::1::DateTime::NEEDS_y2038 ) {
        *epoch = sub {
            my $self = shift;

            my $zone = $self->time_zone;
            $self->set_time_zone("UTC");

            require Time::y2038;
            my $time = Time::y2038::timegm(
                $self->sec, $self->min, $self->hour, $self->mday,
                $self->mon - 1,
                $self->year - 1900,
            );

            $self->set_time_zone($zone);

            return $time;
        }
    }
}

{

    package perl5i::1::DateTime::time;

    use parent -norequire, qw(perl5i::1::DateTime::y2038);

    use overload
      "0+" => sub { $_[0]->epoch },
      "-"  => sub {
        my( $a, $b, $reverse ) = @_;

        if($reverse) {
            ( $b, $a ) = ( $a, $b );
        }

        my $time_a = eval { $a->isa("DateTime") } ? $a->epoch : $a;
        my $time_b = eval { $b->isa("DateTime") } ? $b->epoch : $b;

        return $time_a - $time_b;
      },

      "+" => sub {
        my( $a, $b, $reverse ) = @_;

        if($reverse) {
            ( $b, $a ) = ( $a, $b );
        }

        my $time_a = eval { $a->isa("DateTime") } ? $a->epoch : $a;
        my $time_b = eval { $b->isa("DateTime") } ? $b->epoch : $b;

        return $time_a + $time_b;
      },

      "==" => sub {
          my($a, $b) = @_;
          return $a+0 == $b+0 if !eval { $b->isa("DateTime") };
          return $a == $b;
      },

      fallback => 1;
}


{

    package perl5i::1::DateTime::Format::CTime;

    use CLASS;

    sub new {
        return bless {}, $CLASS;
    }

    sub format_datetime {
        my $self = shift;
        my $dt   = shift;

        # Straight from the Open Group asctime() docs.
        return sprintf "%.3s %.3s%3d %.2d:%.2d:%.2d %d",
          $dt->day_abbr,
          $dt->month_abbr,
          $dt->mday,
          $dt->hour,
          $dt->min,
          $dt->sec,
          $dt->year,
          ;
    }
}


1;
