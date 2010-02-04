#!/usr/bin/perl

use perl5i::latest;
use Test::More;

sub foo {
    if( want('LIST') ) {
      return 1, 2, 3;
    }
    elsif (want('BOOL')) {
      return 0;
    }
    elsif (want(qw'SCALAR !REF')) {
      return 23;
    }
    elsif (want('HASH')) {
      return { foo => 17, bar => 23 };
    }
    return;  # You have to put this at the end to keep the compiler happy
}


{
    my @list = foo(3, 2, 1);
    for(1..3){
        is( $list[$_-1], $_);
    }
}

{
    ok(!foo());
}

TODO: {
    local $TODO = "want() with prototypes is busted, thinks its CODE";
    is(foo(), 23 );
}

{
    my %foo = %{foo()};

    is($foo{foo}, 17);
    is($foo{bar}, 23);
}


# Don't export any of Want's other functions
{
    ok !defined &rreturn;
    ok !defined &lnoreturn;
}

done_testing();
