#!perl

use perl5i::latest;
use Test::More;

{
    package Foo;
    sub new {
        my $class = shift;
        my $thing = shift;
        return bless $thing, $class;
    }
}

my $obj = Foo->new({ foo => 42 });
is_deeply eval $obj->mo->perl, { foo => 42 };
isa_ok( eval $obj->mo->perl, "Foo");

done_testing();
