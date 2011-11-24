#!/usr/bin/perl

use perl5i::latest;
use Test::More;

note "popn with no args"; {
    my @array = (1, 2, 3);
    my @newarray = @array->popn();

    my @want = (1, 2, 3);
    my @newwant = ();

    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}

note "popn with arg < 0"; {
    my @array = (1, 2, 3);
    my @newarray = @array->popn(-20);

    my @want = (1, 2, 3);
    my @newwant = ();

    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}   

note "popn with arg == 0"; {
    my @array = (1, 2, 3);
    my @newarray = @array->popn(0);

    my @want = (1, 2, 3);
    my @newwant = ();

    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}   

note "popn with arg > 0"; {
    my @array = (1, 2, 3, 4, 5);
    my @newarray = @array->popn(3);

    my @want = (1, 2);
    my @newwant = (3, 4, 5);

    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}

note "popn with arg > length of array"; {
    my @array = (1, 2, 3, 4);
    my @newarray = @array->popn(10);

    my @want = ();
    my @newwant = (1, 2, 3, 4);

    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}

done_testing;
