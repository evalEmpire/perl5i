#!/usr/bin/perl
use strict;
use warnings;

use perl5i::2;
use Test::More;

#nfor

    nfor my ( $x, $y, $z ) ( qw/a b c x y z/ ) {
        ok( $x eq 'a' || $x eq 'x', "First" );
        ok( $y eq 'b' || $y eq 'y', "Second" );
        ok( $z eq 'c' || $z eq 'z', "Third" );
    }

    my %thing = ( a => 'x', b => 'y' );
    nfor my ( $key, $val ) ( %thing ) {
        ok( $key eq 'a' || $key eq 'b', "key" );
        ok( $val eq 'x' || $val eq 'y', "val" );
    }

    $a = 55;
    nfor ( %thing ) {
        ok( $a eq 'a' || $a eq 'b', "key" );
        ok( $b eq 'x' || $b eq 'y', "val" );
    }
    is( $a, 55, "\$a was localized" );

    nfor $a ( qw/a/ ) {
        is( $a, 'a', "One arg" );
    }

    nfor my $x ( qw/a/ ) {
        is( $x, 'a', "One arg" );
    }

    my $last;
    nfor my $x ( qw/a b c/ ) {
        $last = $x;
        last;
    }
    is( $last, 'a', "Broke loop with last" );

#ngrep

    my @list = ngrep my $x { $x =~ m/^[a-zA-Z]$/ } qw/ a 1 b 2 c 3/;
    is_deeply(
        \@list,
        [qw/a b c/],
        "filtered as expected"
    );

#nmap

    @list = nmap my $x { "updated_$x" } qw/ a b c /;
    is_deeply(
        \@list,
        [qw/updated_a updated_b updated_c/],
        "mapped as expected"
    );

#count and vartypes
    my $count = ngrep my $x { $x =~ m/^[a-zA-Z]$/ } qw/ a 1 b 2 c 3/;
    is( $count, 3, "counts properly" );

    my $y;
    $count = ngrep $y { $y =~ m/^[a-zA-Z]$/ } qw/ a 1 b 2 c 3 222/;
    is( $count, 3, "closure block var" );
    is( $y, '222', "Used outer scope var" );

    $count = ngrep our $v { $v =~ m/^[a-zA-Z]$/ } qw/ a 1 b 2 c 3/;
    is( $count, 3, "package block var" );

    $count = ngrep thing { $thing =~ m/^[a-zA-Z]$/ } qw/ a 1 b 2 c 3/;
    is( $count, 3, "shorthand new variable" );

done_testing;
