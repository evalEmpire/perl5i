#!/usr/bin/env perl
use Test::More;
use Test::Exception;
use perl5i::latest;

{
    # Error checking

    my $h;

    is_deeply $h = { a => 1 }->diff, { a => 1 };
    is_deeply $h = {}->diff(), {};
    is_deeply $h = {}->diff( {} ), {};
    throws_ok { $h = {}->diff('foo') } qr/Arguments must be/;
}

{
    my %first = ( foo => 1, bar => 2, baz => 3 );

    my %second = (foo => 1, baz => 2);

    my %diff = %first->diff(\%second);

    is_deeply \%diff, { bar => 2, baz => 3 };
}

{
    my %first  = ( foo => { bar => 1 }, baz => 3 );
    my %second = ( foo => 2, baz => 3 );
    my %third  = ( foo => { bar => 2 }, quux => [ 'hai' ] );

    my %diff = %first->diff(\%second, \%third);

    is_deeply \%diff, { foo => { bar => 1 } };
}

done_testing;
