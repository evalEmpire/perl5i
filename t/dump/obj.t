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

my $hash = { foo => 42 };
my $obj = Foo->new($hash);
is_deeply eval $obj->mo->perl, $hash;
isa_ok( eval $obj->mo->perl, "Foo");

is_deeply eval $obj->mo->dump, $hash;
is_deeply eval $obj->mo->dump( format => "perl" ), $hash;

{
    use JSON;
    is_deeply from_json( $obj->mo->dump( format => "json" ) ), $hash;
}

{
    use YAML::Any;
    is_deeply Load( $obj->mo->dump( format => "yaml" ) ), $obj, "dump as yaml";
}

done_testing();
