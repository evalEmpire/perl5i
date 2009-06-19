package perl5i::DateTime;

# A file to contain the Datetime work for perl5i to get it out of perl5i.pm

use 5.010;
use strict;
use warnings;


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_gmtime (;$) {
    my $time = @_ ? shift : time;
    return CORE::gmtime($time) if wantarray;

    require DateTime;
    return DateTime::y2038->from_epoch(
        epoch     => $time + 0,
        formatter => "DateTime::Format::CTime"
    );
}


## no critic (Subroutines::ProhibitSubroutinePrototypes)
sub dt_localtime (;$) {
    my $time = @_ ? shift : time;
    return CORE::localtime($time) if wantarray;

    require DateTime;
    return DateTime::y2038->from_epoch(
        epoch     => $time + 0,
        time_zone => "local",
        formatter => "DateTime::Format::CTime"
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

    # Override gmtime and localtime with straight emulations
    # so we can override it later.
    {
        *CORE::GLOBAL::gmtime = sub (;$) {
            return @_ ? CORE::gmtime( $_[0] ) : CORE::gmtime();
        };

        *CORE::GLOBAL::localtime = sub (;$) {
            return @_ ? CORE::localtime( $_[0] ) : CORE::localtime();
        };
    }

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
