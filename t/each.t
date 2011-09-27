#!/usr/bin/perl

use perl5i::latest;
use Test::More;

note "each with no signature"; {
    my %want = (foo => 23, bar => 42);

    my %have;
    %want->each( sub { $have{$_[0]} = $_[1] } );

    is_deeply \%have, \%want;
}

done_testing;
