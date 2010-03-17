#!/usr/bin/perl

use Test::More;

plan skip_all => "Needs Time::y2038" unless eval { require Time::y2038 };

use_ok 'perl5i::0';

done_testing();
