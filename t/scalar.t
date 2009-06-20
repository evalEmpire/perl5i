#!perl

use Test::More 'no_plan';
use perl5i;

is( "this is a test"->ucfirst_word, 'This Is A Test');
is( "this is a test"->lc->ucfirst_word, 'This Is A Test');

is( "thIS is a teST"->ucfirst_word, 'ThIS Is A TeST');
is( "thIS is a teST"->lc->ucfirst_word, 'This Is A Test');

is( '    testme'->ltrim, 'testme' );
is( '    testme'->rtrim, '    testme' );
is( '    testme'->trim,  'testme' );

is( 'testme    '->ltrim, 'testme    ' );
is( 'testme    '->rtrim, 'testme' );
is( 'testme    '->trim,  'testme' );

is( '    testme    '->ltrim, 'testme    ' );
is( '    testme    '->rtrim, '    testme' );
is( '    testme    '->trim,  'testme' );

