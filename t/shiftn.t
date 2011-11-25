#!/usr/bin/perl

use lib 't/lib';
use Test::perl5i;
use perl5i::2;
use Test::More;

note "shiftn with no args"; {
    my @array = (1, 2, 3);
    throws_ok { @array->shiftn(); }
      qr{^\Qshiftn() takes the number of elements to shift at $0 line };
}

note "shiftn with negative arg"; {
    my @array = (1, 2, 3);
    throws_ok { @array->shiftn(-20); }
      qr{^\Qshiftn() takes a positive integer or zero, not '-20' at $0 line };
}   

note "shiftn with non-numerical argument"; {
    my @array = (1, 2, 3);
    throws_ok { @array->shiftn("meow"); }
      qr{^\Qshiftn() takes a positive integer or zero, not 'meow' at $0 line };
}

note "shiftn with arg == 0"; {
    my @array = (1, 2, 3);
    my @newarray = @array->shiftn(0);
    
    my @want = (1, 2, 3);
    my @newwant = ();
    
    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}

note "shiftn with arg > 0"; {
    my @array = (1, 2, 3, 4, 5);
    my @newarray = @array->shiftn(3);
    
    my @want = (4, 5);
    my @newwant = (1, 2, 3);
    
    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}

note "shiftn with arg > length of array"; {
    my @array = (1, 2, 3, 4);
    my @newarray = @array->shiftn(50);

    my @want = ();
    my @newwant = (1, 2, 3, 4);
    
    is_deeply \@array, \@want;
    is_deeply \@newarray, \@newwant;
}

note "shiftn in scalar context"; {
    my $array = [1,2,3,4,5];
    my $new = $array->shiftn(3);

    is_deeply $array, [4,5];
    is_deeply $new, [1,2,3];
}

done_testing();
