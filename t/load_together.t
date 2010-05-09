#!/usr/bin/perl

my @warnings;
BEGIN {
    $SIG{__WARN__} = sub {
        push @warnings, @_;
    };
}

use Test::More;

{
    package Foo;
    use perl5i::1;
}
{
    package Bar;
    use perl5i::2;
}

TODO:{
    local $TODO = "loading perl5i::1 and perl5i::2 together not entirely safe";
    is @warnings, 0, "no warnings" or diag explain \@warnings;
}

done_testing;
