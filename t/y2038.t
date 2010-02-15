#!perl

use perl5i::latest;
use Test::More 'no_plan';

TODO: {
    my $time = gmtime( 2**35 );
    is $time->year,  3058;
    is $time->epoch, 2**35;
}
