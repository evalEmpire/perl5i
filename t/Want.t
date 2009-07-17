#!/usr/bin/perl

use perl5i;
use Test::More;

sub foo :lvalue {
    if    (want(qw'LVALUE ASSIGN')) {
      want('ASSIGN');
      lnoreturn;
    }
    elsif (want('LIST')) {
      rreturn (1, 2, 3);
    }
    elsif (want('BOOL')) {
      rreturn 0;
    }
    elsif (want(qw'SCALAR !REF')) {
      rreturn 23;
    }
    elsif (want('HASH')) {
      rreturn { foo => 17, bar => 23 };
    }
    return;  # You have to put this at the end to keep the compiler happy
}


{
    is( ( foo() = 100 ), 100, 'assignment worked' );
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

done_testing();
