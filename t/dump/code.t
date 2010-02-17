#!perl

# Test dumping code refs

use perl5i::latest;
use Test::More;

sub code_dump_ok($$;$) {
    my( $code, $want, $name ) = @_;

    my $ref = eval( $code->perl );
    ok( $ref, "dump eval'd" ) or do { diag $@; return; };
    is_deeply [ $ref->() ], $want, $name;
}


# Test closures
{
    my $foo = 42;

    sub closure {
        return $foo;
    }
}

my $closure = \&closure;
TODO: {
    local $TODO = "closures aren't dumped properly";
    code_dump_ok $closure, [42], "scalar code ref dump";
}

code_dump_ok sub { 23 }, [23], "anon sub dump";

done_testing();
