#!/usr/bin/perl -w

use perl5i::latest;
use Test::More;

eval { die };
ok $EVAL_ERROR;
is $EVAL_ERROR, $@;

ok !eval q{ $PREMATCH;  1 };
ok !eval q{ $MATCH;     1 };
ok !eval q{ $POSTMATCH; 1 };

done_testing;
