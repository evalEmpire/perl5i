#!perl

use perl5i::latest;
use Test::More;

my $ref = [1..10];

is_deeply $ref->mo->as_perl, $ref->mo->perl, 'perl';
is_deeply $ref->mo->as_json, $ref->mo->dump(format=>'json'), 'json';
is_deeply $ref->mo->as_yaml, $ref->mo->dump(format=>'yaml'), 'yaml';

done_testing;

