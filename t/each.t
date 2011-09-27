#!/usr/bin/perl

use perl5i::latest;
use Test::More;

note "each with no signature"; {
    my %want = (foo => 23, bar => 42);

    my %have;
    %want->each( sub { $have{$_[0]} = $_[1] } );

    is_deeply \%have, \%want;
}


note "each with one arg"; {
    my %want = (foo => 23, bar => 42);

    my %have;
    %want->each( func($k) { $have{$k} = 1 } );

    is_deeply \%have, { foo => 1, bar => 1 };
}


note "each with two args"; {
    my %want = (foo => 23, bar => 42);

    my %have;
    %want->each( func($k,$v) { $have{$k} = $v } );

    is_deeply \%have, \%want;
}


note "each call is safe"; {
    my %want = (foo => 23, bar => 42, baz => 99, biff => 66);

    # Call each once on %want to start the iterator attached to %want
    my($k,$v) = each %want;

    my %have;
    %want->each( func($k,$v) { $have{$k} = $v } );

    is_deeply \%have, \%want;
}

done_testing;
