package perl5i::DateTime;

# A file to contain the Datetime work for perl5i to get it out of perl5i.pm

use 5.010;
use strict;
use warnings;
use Time::y2038;


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_gmtime (;$) {
    my $time = @_ ? shift : time;
    return gmtime($time) if wantarray;

    my($sec, $min, $hour, $mday, $mon, $year) = gmtime($time);
    $mon++;
    $year += 1900;

    require DateTime;
    return DateTime::y2038->new(
        year            => $year,
        month           => $mon,
        day             => $mday,
        hour            => $hour,
        minute          => $min,
        second          => $sec,
        formatter       => "DateTime::Format::CTime"
    );
}


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_localtime (;$) {
    my $time = @_ ? shift : time;
    return localtime($time) if wantarray;

    my($sec, $min, $hour, $mday, $mon, $year) = localtime($time);
    $mon++;
    $year += 1900;

    require DateTime;
    return DateTime::y2038->new(
        year            => $year,
        month           => $mon,
        day             => $mday,
        hour            => $hour,
        minute          => $min,
        second          => $sec,
        time_zone       => "local",
        formatter       => "DateTime::Format::CTime"
    );
}


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_time () {
    require DateTime::Format::Epoch;
    state $formatter = DateTime::Format::Epoch->new( epoch => DateTime->from_epoch( epoch => 0 ) );

    require DateTime;
    return DateTime::time->from_epoch(
        epoch     => time,
        formatter => $formatter
    );
}


{
    package DateTime::y2038;

    # Don't load DateTime until we need it.
    our @ISA = qw(DateTime);

    sub from_epoch {
        my $class = shift;

        require Time::y2038;
        no warnings 'redefine';
        local *CORE::GLOBAL::gmtime    = \&Time::y2038::gmtime;
        local *CORE::GLOBAL::localtime = \&Time::y2038::localtime;

        return $class->SUPER::from_epoch(@_);
    }


    # Copy of DateTime's own epoch() function.
    sub epoch {
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

{

    package DateTime::time;

    use parent -norequire, qw(DateTime::y2038);

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

      fallback => 1;
}


{

    package DateTime::Format::CTime;

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
