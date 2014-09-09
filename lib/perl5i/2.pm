# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2;

use 5.010;

use strict;
use warnings;

#This should come first
use perl5i::2::RequireMessage;

use Carp::Fix::1_25;
use perl5i::2::autobox;
use Import::Into;

use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

our $Latest = perl5i::VERSION->latest;

my %Features = (
    # A stub for autodie.  It's handled specially in import().
    autodie => sub {},
    autobox => sub {
        my ($class, $caller) = @_;
        perl5i::2::autobox->import::into($caller);
    },
    autovivification => sub {
        my ($class, $caller) = @_;
        autovivification->unimport::out_of($caller);
    },
    capture => sub {
        my ($class, $caller) = @_;
        (\&capture)->alias($caller, "capture");
    },
    "Carp::Fix::1_25" => sub {
        my ($class, $caller) = @_;
        Carp::Fix::1_25->import::into($caller);
    },
    Child => sub {
        my ($class, $caller) = @_;
        Child->import::into( $caller => qw(child) );
    },
    CLASS => sub {
        my ($class, $caller) = @_;
        CLASS->import::into( $caller );
    },
    die => sub {
        my ($class, $caller) = @_;
        (\&perl5i_die)->alias($caller, "die");
    },
    English => sub {
        my ($class, $caller) = @_;
        English->import::into( $caller => qw(-no_match_vars) );
    },
    'File::chdir' => sub {
        my ($class, $caller) = @_;
        File::chdir->import::into( $caller );
    },
    indirect => sub {
        my ($class, $caller) = @_;
        indirect->unimport::out_of($caller, ":fatal");
    },
    list => sub {
        my ($class, $caller) = @_;
        (\&force_list_context)->alias($caller, 'list');
    },
    Meta => sub {
        require perl5i::2::Meta;
    },
    'Modern::Perl' => sub {
        my ($class, $caller) = @_;

        # use Modern::Perl
        Modern::Perl->import::into($caller);

        # no strict vars for oneliners - GH #63
        strict::unimport($class, 'vars')
            if $class eq 'perl5i::cmd'
            or $0 eq '-e';

        # Modern::Perl won't pass this through to our caller.
        require mro;
        mro::set_mro($caller, 'c3');
    },
    'Perl6::Caller' => sub {
        my ($class, $caller) = @_;
        Perl6::Caller->import::into($caller);
    },
    Signatures => sub {
        my ($class, $caller) = @_;
        perl5i::2::Signatures->import::into($caller);
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
    true => sub {
        my ($class, $caller) = @_;
        true->import::into($caller);
    },
    'Try::Tiny' => sub {
        my ($class, $caller) = @_;
        Try::Tiny->import::into($caller);
    },
    'utf8::all' => sub {
        my ($class, $caller) = @_;
        utf8::all->import::into($caller);
        "feature"->unimport::out_of($caller, "unicode_eval") if $^V >= v5.16.0;
    },
    Want => sub {
        my ($class, $caller) = @_;
        Want->import::into( $caller => qw(want) );
    },
);

# This is necessary for autodie to work and be lexical
use parent 'autodie';

## no critic (Subroutines::RequireArgUnpacking)
sub import {
    my $class = shift;
    my %import = @_;

    my $caller = caller;

    # Read the skip list and turn it into a hash
    my $skips = delete $import{-skip} || [];
    $skips = { map { $_ => 1 } @$skips };

    # Any remaining import parameters are unknown
    if( keys %import ) {
        croak sprintf "Unknown parameters '%s' in import list",
          join(", ", map { "$_ => $import{$_}" } keys %import);
    }

    # Check all the skipped features are valid
    for my $f ( grep { !exists $Features{$_} } keys %$skips ) {
        croak "Unknown feature '$f' in skip list";
    }

    # Current lexically active major version of perl5i.
    $^H{perl5i} = 2;

    # Load all the features.
    for my $feature (keys %Features) {
        next if $skips->{$feature};
        $Features{$feature}->($class, $caller);
    }

    # autodie needs a bit more convincing
    if( !$skips->{autodie} ) {
        @_ = ( $class, ":all" );
        goto &autodie::import;
    }
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

1;
