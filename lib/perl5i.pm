# vi: set ts=4 sw=4 ht=4 et :
package perl5i;

use 5.010;

use strict;
use warnings;
use Module::Load;
use Carp;

our $VERSION = '20090614';


=head1 NAME

perl5i - Bend Perl 5 so it fits how it works in my imagination

=head1 SYNOPSIS

  use perl5i;

=head1 DESCRIPTION

B<THIS MODULE'S INTERFACE IS UNSTABLE!> It's still a playground.
Features may be added, changed and removed without notice.  You have
been warned.

Perl 5 has a lot of warts.  There's a lot of individual modules and
techniques out there to fix those warts.  perl5i aims to pull the best
of them together into one module so you can turn them on all at once.

This includes adding features, changing existing core functions and
changing defaults.  It will likely not be backwards compatible with
Perl 5, so perl5i will try to have a lexical effect.

Please add to my imaginary world, either by telling me what Perl looks
like in your imagination (F<http://github.com/schwern/perl5i/issues>
or make a fork (forking on github is like a branch you control) and
implement it yourself.

=head1 What it does

perl5i enables each of these modules and adds/changes these functions.
We'll provide a brief description here, but you should look at each of
their documentation for full details.

=head2 alias()

    alias( $name           => $reference );
    alias( $package, $name => $reference );
    alias( @identifiers    => $reference );

Assigns a $refrence a $name.  For example...

    alias foo => sub { 42 };
    print foo();        # prints 42

It will also work on hash, array and scalar refs.

    our %stuff;
    alias stuff => \%some_other_hash;

Multiple @identifiers will be joined with '::' and used as the fully
qualified name for the alias.

    my $class = "Some::Class";
    my $name  = "foo";
    alias $class, $name => sub { 99 };
    print Some::Class->foo;  # prints 99

If the $name has no "::" in it, the current caller will be prepended.

This is basically a nicer way to say:

    no strict 'refs';
    *{$package . '::'. $name} = $reference;

=cut

sub alias {
    croak "Not enough arguments given to alias()" unless @_ >= 2;

    my $thing = pop @_;
    croak "Last argument to alias() must be a reference" unless ref $thing;

    my @name = @_;
    unshift @name, (caller)[0] unless grep /::/, @name;

    my $name = join "::", @name;

    no strict 'refs';
    *{$name} = $thing;
    return;
}


=head2 die()

C<die> now always returns an exit code of 255 instead of trying to use
C<$!> or C<$?> which makes the exit code unpredictable.  If you want
to exit with a message and a special message, use C<warn> then
C<exit>.

=head2 Modern::Perl

Turns on strict and warnings, enables all the 5.10 features like
C<given/when>, C<say> and C<state>, and enables C3 method resolution
order.

=head2 CLASS

Provides C<CLASS> and C<$CLASS> alternatives to C<__PACKAGE__>.

=head2 File::stat

L<File::stat> causes C<stat> to return objects rather than long arrays
which you never remember which bit is which.

=head2 DateTime

C<time>, C<localtime> and C<gmtime> are replaced with DateTime
objects.  They will all act like the core functions.

    # Sat Jan 10 13:37:04 2004
    say scalar gmtime(2**30);

    # 2004
    say gmtime(2**30)->year;

    # 2009 (when this was written)
    say time->year;


=head2 Time::y2038

gmtime() and localtime() will now safely work with dates beyond the
year 2038 and before 1901 (the exact range is not defined, but its
well into a couple million years in either direction).


=head2 Module::Load

L<Module::Load> adds C<load> which will load a module from a scalar
without requiring you to do funny things like C<eval require $module>.


=head2 autodie

L<autodie> causes system and file calls which can fail
(C<open>, C<system> and C<chdir>, for example) to die when they fail.
This means you don't have to put C<or die> at the end of every system
call, but you do have to wrap it in an C<eval> block if you want to
trap the failure.

autodie's default error messages are pretty smart.

All of autodie will be turned on.


=head2 autobox

L<autobox> allows methods to defined for and called on most unblessed
variables.

=head2 autobox::Core

L<autobox::Core> wraps a lot of Perl's built in functions so they can
be called as methods on unblessed variables.  C<< @a->pop >> for example.

=head2 autobox::List::Util

L<autobox::List::Util> wraps the functions from List::Util
(first, max, maxstr, min, minstr, shuffle, reduce, and sum)
so they can be called on arrays and arrayrefs.

=head2 autobox::dump

L<autobox::dump> defines a C<perl> method that returns L<Data::Dumper>
style serialization of the results of the expression.


=head1 BUGS

Some parts are not lexical.


=head1 NOTES

Inspired by chromatic's L<Modern::Perl> and in particular
F<http://www.modernperlbooks.com/mt/2009/04/ugly-perl-a-lesson-in-the-importance-of-language-design.html>.

I totally didn't come up with the "Perl 5 + i" joke.  I think it was
Damian Conway.


=head1 LICENSE

Copyright 2009, Michael G Schwern <schwern@pobox.com>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>


=head1 SEE ALSO

Repository:   F<http://github.com/schwern/perl5i/tree/master>
Issues/Bugs:  F<http://github.com/schwern/perl5i/issues>

L<Modern::Perl>


=cut

# This works around their lexical nature.
use parent 'autodie';
# List::Util needs to be before Core to get the C version of sum
use parent 'autobox::List::Util';
use parent 'autobox::Core';
use parent 'autobox::dump';

## no critic (Subroutines::RequireArgUnpacking)
sub import {
    my $class = shift;

    require Modern::Perl;
    Modern::Perl->import;

    my $caller = caller;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( $caller, 'c3' );

    load_in_caller( $caller => ( ["CLASS"], ["File::stat"], ["Module::Load"], ) );

    # Have to call both or it won't work.
    autobox::import($class);
    autobox::List::Util::import($class);
    autobox::Core::import($class);
    autobox::dump::import($class);

    # Export our gmtime() and localtime()
    {
        no strict 'refs';
        *{ $caller . '::gmtime' }    = \&dt_gmtime;
        *{ $caller . '::localtime' } = \&dt_localtime;
        *{ $caller . '::time' }      = \&dt_time;
        *{ $caller . '::alias' }     = \&alias;
    }

    # fix die so that it always returns 255
    *CORE::GLOBAL::die = sub {
        my $error = join '', @_;
        unless ($error =~ /\n$/) {
            my ($file, $line) = (caller)[1,2];
            $error .= " at $file line $line.\n";
        }

        local $! = 255;
        return CORE::die($error);
    };

    # autodie needs a bit more convincing
    @_ = ( $class, ":all" );
    goto &autodie::import;
}


sub load_in_caller {
    my $caller  = shift;
    my @modules = @_;

    for my $spec (@modules) {
        my( $module, @args ) = @$spec;

        load($module);
        ## no critic (BuiltinFunctions::ProhibitStringyEval)
        eval qq{
            package $caller;
            \$module->import(\@args);
            1;
        } or die "Error while perl5i loaded $module => @args: $@";
    }

    return;
}


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
