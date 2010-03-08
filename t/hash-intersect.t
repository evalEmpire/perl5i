#!/usr/bin/env perl
use Test::More;
use Test::Exception;
use perl5i::latest;

{
    # Error checking

    my $h;

    is_deeply $h = { a => 1 }->intersect, { a => 1 };
    is_deeply $h = {}->intersect(), {};
    is_deeply $h = {}->intersect( {} ), {};
    throws_ok { $h = {}->intersect('foo') } qr/Arguments must be/;
}

{
    my %first = ( foo => 1, bar => 2, baz => 3 );

    my %second = (foo => 1, baz => 2);

    my %intersect = %first->intersect(\%second);

    is_deeply \%intersect, { foo => 1 };
}

{
    my %first  = ( foo => { bar => 1 }, baz => 3 );
    my %second = ( foo => { bar => 1 }, baz => 3 );
    my %third  = ( foo => { bar => 1 }, quux => [ 'hai' ] );

    my %intersect = %first->intersect(\%second, \%third);

    is_deeply \%intersect, { foo => { bar => 1 } };
}

done_testing;
