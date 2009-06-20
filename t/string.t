#!perl

use Test::More 'no_plan';
use perl5i;

is( "this is a test"->ucfirst_word, 'This Is A Test');
is( "this is a test"->lc_ucfirst_word, 'This Is A Test');

is( "thIS is a teST"->ucfirst_word, 'ThIS Is A TeST');
is( "thIS is a teST"->lc_ucfirst_word, 'This Is A Test');

