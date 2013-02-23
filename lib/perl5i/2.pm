# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2;

use 5.010;

use strict;
use warnings;

#This should come first
use perl5i::2::RequireMessage;

use IO::Handle;
use Carp::Fix::1_25;
use perl5i::2::Meta;
use Encode ();
use perl5i::2::autobox;
use true;

use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

our $Latest = perl5i::VERSION->latest;


# This works around their lexical nature.
use parent 'autodie';
use parent 'perl5i::2::autobox';
use parent 'autovivification';
use parent 'indirect';
use parent 'utf8::all';

my %Features = (
    capture => sub {
        my($class, $caller) = @_;
        (\&capture)->alias($caller, "capture");
    },
    Child => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['Child' => qw(child)]);
    },
    CLASS => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['CLASS']);
    },
    die => sub {
        my ($class, $caller) = @_;
        (\&perl5i_die)->alias($caller, "die");
    },
    English => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['English' => qw(-no_match_vars)]);
    },
    'File::chdir' => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['File::chdir']);
    },
    'Perl6::Caller' => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['Perl6::Caller']);
    },
    stat => sub {
        my ($class, $caller) = @_;
        require File::stat;
        # Export our stat and lstat
        (\&stat)->alias($caller, 'stat');
        (\&lstat)->alias($caller, 'lstat');
    },
    time => sub {
        my ($class, $caller) = @_;
        require perl5i::2::DateTime;
        # Export our gmtime() and localtime()
        (\&perl5i::2::DateTime::dt_gmtime)->alias($caller, 'gmtime');
        (\&perl5i::2::DateTime::dt_localtime)->alias($caller, 'localtime');
        (\&perl5i::2::DateTime::dt_time)->alias($caller, 'time');
    },
    'Try::Tiny'   => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['Try::Tiny']);
    },
    Want => sub {
        my ($class, $caller) = @_;
        load_in_caller($caller, ['Want' => qw(want)]);
    },
);

## no critic (Subroutines::RequireArgUnpacking)
sub import {
    my $class = shift;

    require Modern::Perl;
    Modern::Perl->import;

    my $caller = caller;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( $caller, 'c3' );

    load_in_caller( $caller => (
        ['Carp::Fix::1_25'],
        ['perl5i::2::Signatures'],
    ) );
    # no strict vars for oneliners - GH #63
    strict::unimport($class, 'vars')
        if $class eq 'perl5i::cmd'
        or $0 eq '-e';

    # Have to call both or it won't work.
    true::import($class);
    perl5i::2::autobox::import($class);
    autovivification::unimport($class);
    indirect::unimport($class, ":fatal");

    utf8::all::import($class);
    (\&perl5i::latest::open)->alias($caller, 'open');

    # Export list()
    (\&force_list_context)->alias($caller, 'list');

    # Current lexically active major version of perl5i.
    $^H{perl5i} = 2;

    for my $feature (values %Features) {
        $feature->($class, $caller);
    }

    # autodie needs a bit more convincing
    @_ = ( $class, ":all" );
    goto &autodie::import;
}

sub unimport { $^H{perl5i} = 0 }

# fix die so that it always returns 255
sub perl5i_die {
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


sub capture(&;@) {
    my($code, %opts) = @_;

    # valid options
    state $valid_options = { map { $_ => 1 } qw(merge tee) };

    for my $key (keys %opts) {
        croak "$key is not a valid option to capture()" unless $valid_options->{$key};
    }

    my $opts = join "/", sort { $a cmp $b } grep { $opts{$_} } keys %opts;

    # Translate option combinations into Capture::Tiny functions
    require Capture::Tiny;
    state $captures = {
        ""              => \&Capture::Tiny::capture,
        "tee"           => \&Capture::Tiny::tee,
        "merge"         => \&Capture::Tiny::capture_merged,
        "merge/tee"     => \&Capture::Tiny::tee_merged
    };

    my $func = $captures->{$opts};
    return $func->($code);
}


sub force_list_context(@) {
    return @_;
}
