#!/usr/bin/perl

use perl5i;
use Test::More 'no_plan';

load "Text::Parsewords";
ok $INC{"Text/Parsewords.pm"}, "load()";
