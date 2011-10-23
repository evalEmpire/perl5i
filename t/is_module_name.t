#!perl

# Before Test::More is loaded so it is utf8'd.
use perl5i::latest;
use Test::More;

my @valid_names = (
    "foo",
    "bar123",
    "Foo213::456",
    "f",
    "a::b",
    "öø::bår",
);

my @invalid_names = (
    "::a::c",
    "123",
    "1abc",
    'foo$bar',
    '$foo::bar',
    'foo/bar'
);

for my $name (@valid_names) {
    ok $name->is_module_name, "valid: $name";
} 

for my $name (@invalid_names) {
    ok !$name->is_module_name, "invalid: $name";
} 

done_testing;
