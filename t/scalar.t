#!perl

use Test::More 'no_plan';
use perl5i::latest;

is( "this is a test"->title_case, 'This Is A Test');
is( "this is a test"->lc->title_case, 'This Is A Test');

is( "thIS is a teST"->title_case, 'ThIS Is A TeST');
is( "thIS is a teST"->lc->title_case, 'This Is A Test');

is( '    testme'->ltrim, 'testme' );
is( '    testme'->rtrim, '    testme' );
is( '    testme'->trim,  'testme' );

is( 'testme    '->ltrim, 'testme    ' );
is( 'testme    '->rtrim, 'testme' );
is( 'testme    '->trim,  'testme' );

is( '    testme    '->ltrim, 'testme    ' );
is( '    testme    '->rtrim, '    testme' );
is( '    testme    '->trim,  'testme' );

is( '--> testme <--'->ltrim("-><"), ' testme <--' );
is( '--> testme <--'->rtrim("-><"), '--> testme ' );
is( '--> testme <--'->trim("-><"),  ' testme ' );

is( ' --> testme <--'->trim("-><"),  ' --> testme ' );
