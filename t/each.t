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

note "Tests adapted from Hash::StoredIterator";

my @want_outer = (
    [a => 1],
    [b => 2],
    [c => 3],
);

my @want_inner = (
    [a => 1],
    [a => 1],
    [a => 1],
    [b => 2],
    [b => 2],
    [b => 2],
    [c => 3],
    [c => 3],
    [c => 3],
);

my %hash = ( a => 1, b => 2, c => 3 );

sub interference {
    my @garbage = keys(%hash), values(%hash);
    while ( my ( $k, $v ) = each(%hash) ) {
        # Effectively do nothing
        my $foo = $k . $v;
    }
};

{
    my @inner;
    my @outer;

    %hash->each( func( $k, $v ) {
        ok( $k, "Got key" );
        ok( $v, "Got val" );
        is( $k, $_, '$_ is set to key' );
        is( $k, $a, '$a is set to key' );
        is( $v, $b, '$b is set to val' );

        push @outer => [$k, $v];
        interference();

        %hash->each( func( $k2, $v2 ) {
            is( $k2, $_, '$_ is set to key' );
            is( $k2, $a, '$a is set to key' );
            is( $v2, $b, '$b is set to val' );

            push @inner => [$k, $v];

            interference();
        });

        is( $k, $_, '$_ is not squashed by inner loop' );
        is( $k, $a, '$a is not squashed by inner loop' );
        is( $v, $b, '$a is not squashed by inner loop' );
    });

    is_deeply(
        [sort { $a->[0] cmp $b->[0] } @outer],
        \@want_outer,
        "Outer loop got all keys"
    );

    is_deeply(
        [sort { $a->[0] cmp $b->[0] } @inner],
        \@want_inner,
        "Inner loop got all keys multiple times"
    );
}

done_testing;
