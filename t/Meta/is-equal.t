#!/usr/bin/env perl
use Test::More;
use perl5i::latest;

{
    my @things = ( [ 42 ], { 4 => 2 }, \42, sub { 42 }, \*STDIN, bless({}, 'Foo') );

    ok $_->mo->is_equal($_) for @things;


    for my $i ( 0 .. $#things ) {

        my @others = grep { $_ ne $i } (0 .. $#things);

        ok( !$things[$i]->mo->is_equal( $things[$_] ) ) for @others;
    }


    ok 42->mo->is_equal(42), "Number is equal to itself";

    ok !42->mo->is_equal($_) for @things;
}

done_testing();
