#!perl -w

use perl5i::2; # I did not see any testing README for how to introduce a
               # version specific change? Is everything expected to be latest?
use Test::More tests => 3;

my $ref = [1..10];

is_deeply $ref->mo->as_perl, $ref->mo->perl, 'perl';
is_deeply $ref->mo->as_json, $ref->mo->dump(format=>'json'), 'json';
is_deeply $ref->mo->as_yaml, $ref->mo->dump(format=>'yaml'), 'yaml';
