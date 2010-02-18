# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0;

use 5.010;

use strict;
use warnings;
use Module::Load;
use IO::Handle;
use Carp;
use perl5i::0::DateTime;
use perl5i::0::SCALAR;
use perl5i::0::ARRAY;
use perl5i::0::HASH;
use Want;
use Try::Tiny;
use perl5i::0::Meta;

use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

our $Latest = perl5i::VERSION->latest;

sub alias {
    croak "Not enough arguments given to alias()" unless @_ >= 2;

    my $thing = pop @_;
    croak "Last argument to alias() must be a reference" unless ref $thing;

    my @name = @_;
    unshift @name, (caller)[0] unless @name > 1 or grep /::/, @name;

    my $name = join "::", @name;

    no strict 'refs';
    *{$name} = $thing;
    return;
}


# This works around their lexical nature.
use parent 'autodie';
# List::Util needs to be before Core to get the C version of sum
use parent 'autobox::List::Util';
use parent 'autobox::Core';
use parent 'autobox::dump';
use parent 'autovivification';
use parent 'utf8';

## no critic (Subroutines::RequireArgUnpacking)
sub import {
    my $class = shift;

    require File::stat;

    require Modern::Perl;
    Modern::Perl->import;

    my $caller = caller;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( $caller, 'c3' );

    load_in_caller( $caller => (
        ["CLASS"], ["File::chdir"],
        [English => qw(-no_match_vars)],
        ["Want" => qw(want)], ["Try::Tiny"], ["Perl6::Caller"],
    ) );

    # Have to call both or it won't work.
    autobox::import($class);
    autobox::List::Util::import($class);
    autobox::Core::import($class);
    autobox::dump::import($class);
    autovivification::unimport($class);
    utf8::import($class);

    # Export our gmtime() and localtime()
    alias( $caller, 'gmtime',    \&{$Latest .'::DateTime::dt_gmtime'} );
    alias( $caller, 'localtime', \&{$Latest .'::DateTime::dt_localtime'} );
    alias( $caller, 'time',      \&{$Latest .'::DateTime::dt_time'} );
    alias( $caller, 'alias',     \&alias );
    alias( $caller, 'stat',      \&stat );
    alias( $caller, 'lstat',     \&lstat );

    # fix die so that it always returns 255
    *CORE::GLOBAL::die = sub {
        # Leave a single ref be
        local $! = 255;
        return CORE::die(@_) if @_ == 1 and ref $_[0];

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


# File::stat does not play nice in list context
sub stat {
    return CORE::stat(@_) if wantarray;
    return File::stat::stat(@_);
}

sub lstat {
    return CORE::lstat(@_) if wantarray;
    return File::stat::lstat(@_);
}

1;
