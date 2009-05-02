#!/usr/bin/perl -w

use perl5i;

use Test::More 'no_plan';

sub is_about {
    my($a, $b, $name) = @_;

    my $tb = Test::More->builder;

    my $test = (abs($a - $b) <= 1);
    my $ret = $tb->ok($test, $name);
    if( !$ret ) {
        $tb->diag(<<END);
have: $a
want: $b
epsilon: 1
END
    }

    return $ret;
}


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

    like $date." wibble", qr/ wibble$/, "DateTime doesn't bitch on concatenation";
}


# Test time.
TODO: {
    is_about time, CORE::time, "time";
    isa_ok time, "DateTime",                "  is DateTime";
    cmp_ok time->year, ">=", 2009;

    # Tests for subtraction, because DateTime doesn't like that.
    is_about time, time;
    is_about time - time - time, -CORE::time();
    is_about 0-time(), -CORE::time();
    is_about time-0, CORE::time();

    # Test for addition
    is_about time + time, CORE::time + CORE::time;

    # Multiplication
    is_about time * 1, CORE::time;

    # Division
    is_about time / time, 1;
}
