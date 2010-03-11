#!perl

use perl5i::latest;

use Test::More;

# "no indirect" happens at compile time
ok !eval q{
    my $foo = 42;
    foo $foo;
};
like $@, qr[^Indirect call of method "foo" on object "\$foo"];

done_testing();
