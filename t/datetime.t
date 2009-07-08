#!perl -w

use perl5i;

use Test::More 'no_plan';

sub is_about {
    my( $a, $b, $name ) = @_;

    my $tb = Test::More->builder;

    my $test = ( abs( $a - $b ) <= 1 );
    my $ret = $tb->ok( $test, $name );
    if( !$ret ) {
        $tb->diag(<<END);
have: $a
want: $b
epsilon: 1
END
    }

    return $ret;
}


# Use a fixed time because a tick might happen between calls
my $time = int rand( 2**31 - 1 );
note("time is $time");

# Can't take a ref to a core function, so we put a wrapper around them.
my %funcs = (
    localtime => sub { CORE::localtime( $_[0] ) },
    gmtime    => sub { CORE::gmtime( $_[0] ) },
);

for my $name ( keys %funcs ) {
    my $have = \&{$name};
    my $want = $funcs{$name};

    my $date = $have->($time);
    isa_ok $date, 'DateTime', "$name returns a DateTime";

    is $date, $want->($time), "  scalar context";
    is $date->year, ( $want->($time) )[5] + 1900, "  method call";
    is $date->epoch, $time, "  epoch";

    is_deeply [ $have->($time) ], [ $want->($time) ], "  array context";

    cmp_ok $have->()->year, ">=", 2009, "  no args";

    my @args = ($time);
    is $have->(@args), $want->(@args), "  array argument";

    like $date. " wibble", qr/ wibble$/, "DateTime doesn't bitch on concatenation";
}


# Test time.
{
    is_about time, CORE::time, "time";
    isa_ok time, "DateTime", "  is DateTime";
    cmp_ok time->year, ">=", 2009;

    # Tests for subtraction, because DateTime doesn't like that.
    is_about time, time;
    is_about time - time - time, -CORE::time();
    is_about 0 - time(), -CORE::time();
    is_about time - 0, CORE::time();

    # Test for addition
    is_about time + time, CORE::time + CORE::time;

    # Multiplication
    is_about time * 1, CORE::time;

    # Division
    is_about time / time, 1;
}


# test the object nature we are adding
{
    my @methods1 = qw/sec min hour day month year day_of_week day_of_year is_dst/;
    my @methods2 = qw/second minute hour mday mon year dow doy is_dst/;
    my @methods3 = qw/sec min hour day_of_month mon year wday doy is_dst/;

    my $obj      = gmtime($time);
    my @date     = gmtime($time);

    # adjust for object's niceties
    $date[4]++;    # month is 1 - 12 not 0 - 11
    $date[5] += 1900;    # full year, not years since 1900
    $date[6] = 7 if $date[6] == 0;    # In DateTime, Sunday is 7
    $date[7]++;                       # julian is 1 .. 365|366 not 0 .. 354|355

    for my $methods ( \( @methods1, @methods2, @methods3 ) ) {
        is_deeply [@date], [ map { $obj->$_ } @$methods ], "DateTime methods: @$methods";
    }
}
