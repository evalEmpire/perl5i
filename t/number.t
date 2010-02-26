#!perl

use Test::More;
use perl5i::latest;

is( 12.34->ceil,       13);
is( 12.34->round_up,   13);
is( 12.34->floor,      12);
is( 12.34->round_down, 12);
is( 12.34->int, 12);

is( 2.5->round, 3 );
is( 2->round, 2 );
is( 0->round, 0 );
is( 2.51->round, 3 );
is( -3.51->round, -4 );

ok( 12->is_number );
ok(!'FF'->is_number );

ok( 12->is_positive );
ok( "+12"->is_positive );
ok( 12.34->is_positive );
ok( !"foo"->is_positive );
ok( !"-12.2"->is_positive );

ok( !12->is_negative );
ok( "-12"->is_negative );
ok( (-12.34)->is_negative );
ok( !"foo"->is_negative );
ok( "-12.2"->is_negative );

ok !0->is_negative,     "zero is not negative";
ok !0->is_positive,     "zero is not positive";

ok( 12->is_integer );
ok( -12->is_integer );
ok( "+12"->is_integer );
ok(!12.34->is_integer );

ok( 12->is_int );
ok(!12.34->is_int );

ok( 12.34->is_decimal );
ok( ".34"->is_decimal );
ok( !12->is_decimal );
ok(!'abc'->is_decimal );

is( '123'->reverse, '321' );

TODO: {
   local $TODO = q{ hex is weird };

   is( 255->hex, 'FF');
   is( 'FF'->dec, 255);
   is( 0xFF->dec, 255);

};

for my $ref ([ 'foo' ], { bar => 1 }, \'baz', sub { 'gorch' }) {
    for my $method (qw(is_decimal is_integer is_int is_negative is_positive)) {
       ok(!$ref->$method);
    }
}


done_testing();
