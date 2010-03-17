#!perl -w

use perl5i::latest;
use Test::More tests => 5;

my %h = (
    a => 1,
    b => 2,
    c => 3
);
my $ref = \%h;

is_deeply eval( {%h}->mo->perl ), {%h};

is_deeply eval %h->mo->perl, \%h;

is_deeply eval $ref->mo->perl, $ref;

{
    use JSON;
    is_deeply from_json( %h->mo->dump( format => "json" ) ), \%h;
}

{
    use YAML::Any;
    is_deeply Load( %h->mo->dump( format => "yaml" ) ), \%h, "dump as yaml";
}
