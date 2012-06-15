# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2::HASH;
use 5.010;

use strict;
use warnings;

# Don't accidentally turn carp/croak into methods.
require Carp::Fix::1_25;

use perl5i::2::Signatures;

method each($callback) {
    # Reset the each() iterator
    keys %$self;

    my($k,$v);
    while( ($k,$v) = CORE::each(%$self) ) {
        $callback->($k,$v);
    }

    return;
}

sub flip {
    Carp::Fix::1_25::croak("Can't flip hash with references as values")
        if grep { ref } values %{$_[0]};

    my %flipped = reverse %{$_[0]};

    return wantarray ? %flipped : \%flipped;
}

sub merge {
    require Hash::Merge::Simple;
    my $merged = Hash::Merge::Simple::merge(@_);

    return wantarray ? %$merged : $merged;
}

sub print {
    my $hash = shift;
    print join(" ", map { "$_ => $hash->{$_}" } keys %$hash);
}

sub say {
    my $hash = shift;
    print join(" ", map { "$_ => $hash->{$_}" } keys %$hash), "\n";
}

my $common = sub {
    # Return all things in first array that are also present in second.
    my ($c, $d) = @_;

    no warnings 'uninitialized';
    my %seen = map { $_ => 1 } @$d;

    my @common = grep { $seen{$_} } @$c;

    return \@common;
};

sub diff {
    my ($base, @rest) = @_;
    unless (@rest) {
        return wantarray ? %$base : $base;
    }

    die "Arguments must be hash references" if grep { ref $_ ne 'HASH' } @rest;

    # make a copy so that we can delete kv pairs without modifying the
    # original hashref.
    my %base = %$base;

    require perl5i::2::equal;

    foreach my $hash (@rest) {

        my $common_keys = $common->( [ keys %$base ], [ keys %$hash ] );

        next unless @$common_keys;

        # Keys are equal, are values also equal?
        foreach my $key (@$common_keys) {
            delete $base{$key} if perl5i::2::equal::are_equal( $base->{$key}, $hash->{$key} );
        }

    }

    return wantarray ? %base : \%base;
}

my $different = sub {
    # Return all things in first array that are not present in second.
    my ($c, $d) = @_;

    no warnings 'uninitialized';
    my %seen = map { $_ => 1 } @$d;

    my @different = grep { not $seen{$_} } @$c;

    return \@different;
};

sub intersect {
    my ($base, @rest) = @_;

    unless (@rest) {
        return wantarray ? %$base : $base;
    }

    die "Arguments must be hash references" if grep { ref $_ ne 'HASH' } @rest;

    # make a copy so that we can delete kv pairs without modifying the
    # original hashref.
    my %base = %$base;

    require perl5i::2::equal;

    foreach my $hash (@rest) {

        my $different_keys = $different->( [ keys %$base ], [ keys %$hash ] );

        delete @base{@$different_keys};

        return wantarray ? () : {} unless %base;

        my $common_keys = $common->( [ keys %$base ], [ keys %$hash ] );

        # Keys are equal, are values also equal?
        foreach my $key (@$common_keys) {
            delete $base{$key} unless perl5i::2::equal::are_equal( $base->{$key}, $hash->{$key} );
        }

    }

    return wantarray ? %base : \%base;
}

1;
