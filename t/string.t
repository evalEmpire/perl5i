#!perl

use Test::More 'no_plan';
use perl5i;

is( ucfirst_word('this is a test'), 'This Is A Test');
is( ucfirst_word('thIS is a teST'), 'ThIS Is A TeST');

is( lc_ucfirst_word('this is a test'), 'This Is A Test');
is( lc_ucfirst_word('thIS is a teST'), 'This Is A Test');


