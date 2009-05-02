#!/usr/bin/perl -w

use perl5i;

use Test::More 'no_plan';

my $time = int rand(2**31-1);
note("Using $time");

# Can't take a ref to a core function, so we put a wrapper around them.
my %funcs = (
    localtime   => sub { CORE::localtime($_[0]) },
    gmtime      => sub { CORE::gmtime($_[0]) },
);

for my $name (keys %funcs) {
    my $have = \&{$name};
    my $want = $funcs{$name};

    my $date = $have->($time);
    isa_ok $date, 'DateTime', "$name returns a DateTime";

    is $date,          $want->($time),                "  scalar context";
    is $date->year,    ($want->($time))[5] + 1900,    "  method call";
    is $date->epoch,   $time,                         "  epoch";

    is_deeply [$have->($time)], [$want->($time)],   "  array context";

    cmp_ok $have->()->year, ">=", 2009,                 "  no args";

    my @args = ($time);
    is $have->(@args), $want->(@args),                  "  array argument";
}


# Test time.
TODO: {
    todo_skip 'DateTime override of time', 3;

    cmp_ok abs(time - CORE::time), "<=", 1, "time";
    isa_ok time, "DateTime",                "  is DateTime";
    cmp_ok time->year, ">=", 2009;
}
