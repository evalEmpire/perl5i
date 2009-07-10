#!perl

#use Test::More 'no_plan';
use Test::Most 'no_plan';
use perl5i;

is( 12.34->ceil, 13);
is( 12.34->floor, 12);
is( 12.34->int, 12);
ok( 12->is_number );
ok(!'FF'->is_number);


eq_or_diff(
   255->hex,
   'FF',
);
eq_or_diff(
   'FF'->dec,
   255,
);
eq_or_diff(
   0xFF->dec,
   255,
);
