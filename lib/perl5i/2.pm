# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2;

use 5.010;

use strict;
use warnings;
use IO::Handle;
use Carp;
use perl5i::2::DateTime;
use Want;
use Try::Tiny;
use perl5i::2::Meta;
use Encode ();
use perl5i::2::autobox;

use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

our $Latest = perl5i::VERSION->latest;


# This works around their lexical nature.
use parent 'autodie';
use parent 'perl5i::2::autobox';
use parent 'autovivification';
use parent 'indirect';
use parent 'utf8';
use parent 'open';

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
        ["Want" => qw(want)], ["Try::Tiny"], ["Perl6::Caller"], ["Carp"]
    ) );

    # Have to call both or it won't work.
    perl5i::2::autobox::import($class);
    autovivification::unimport($class);
    indirect::unimport($class, ":fatal");
    utf8::import($class);

    open::import($class, ":encoding(utf8)");
    open::import($class, ":std");

    # Export our gmtime() and localtime()
    (\&{$Latest .'::DateTime::dt_gmtime'})->alias($caller, 'gmtime');
    (\&{$Latest .'::DateTime::dt_localtime'})->alias($caller, 'localtime');
    (\&{$Latest .'::DateTime::dt_time'})->alias($caller, 'time');
    (\&stat)->alias( $caller, 'stat' );
    (\&lstat)->alias( $caller, 'lstat' );
    (\&utf8_open)->alias($caller, 'open');

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


    # utf8ify @ARGV
    $_ = Encode::decode('utf8', $_) for @ARGV;


    $^H{perl5i} = 1;

    # autodie needs a bit more convincing
    @_ = ( $class, ":all" );
    goto &autodie::import;
}

sub unimport { $^H{perl5i} = 0 }

sub utf8_open(*;$@) {  ## no critic (Subroutines::ProhibitSubroutinePrototypes)
    my $ret;
    if( @_ == 1 ) {
        $ret = CORE::open $_[0];
    }
    else {
        $ret = CORE::open $_[0], $_[1], @_[2..$#_];
    }

    # Don't try to binmode an unopened filehandle
    return $ret unless $ret;

    my $h = (caller 1)[10];
    binmode $_[0], ":encoding(utf8)" if $h->{perl5i};
    return $ret;
}


sub load_in_caller {
    my $caller  = shift;
    my @modules = @_;

    for my $spec (@modules) {
        my( $module, @args ) = @$spec;

        $module->require;
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

