#!perl

use perl5i;
use Test::More 'no_plan';

load "Text::ParseWords";
ok $INC{"Text/ParseWords.pm"}, "load()";
