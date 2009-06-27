#!perl

use Test::More 'no_plan';
use perl5i;

is( "this is a test"->title, 'This Is A Test');
is( "this is a test"->lc->title, 'This Is A Test');

is( "thIS is a teST"->title, 'ThIS Is A TeST');
is( "thIS is a teST"->lc->title, 'This Is A Test');

is( '    testme'->ltrim, 'testme' );
is( '    testme'->rtrim, '    testme' );
is( '    testme'->trim,  'testme' );

is( 'testme    '->ltrim, 'testme    ' );
is( 'testme    '->rtrim, 'testme' );
is( 'testme    '->trim,  'testme' );

is( '    testme    '->ltrim, 'testme    ' );
is( '    testme    '->rtrim, '    testme' );
is( '    testme    '->trim,  'testme' );

