#!/usr/bin/perl

use lib 't/lib';
use perl5i::latest;
use Test::perl5i;
use Test::More;

note "popn with no args"; {
    my @array = (1, 2, 3);
    throws_ok { @array->popn(); }
      qr{^\Qpopn() takes the number of elements to pop at $0 line };
}

note "popn with negative arg"; {
    my @array = (1, 2, 3);
    throws_ok { @array->popn(-20); }
      qr{^\Qpopn() takes a positive integer or zero, not '-20' at $0 line };
}   

note "popn with non-numerical argument"; {
    my @array = (1, 2, 3);
    throws_ok { @array->popn("rawr"); }
    qr{^\Qpopn() takes a positive integer or zero, not 'rawr' at $0 line };
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

note "popn in scalar context"; {
    my $array = [1,2,3,4,5];
    my $new = $array->popn(3);

    is_deeply $array, [1,2];
    is_deeply $new, [3,4,5];
}

done_testing;
