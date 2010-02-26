#!/usr/bin/env perl
use Test::More;
use perl5i::latest;

my $foo  = bless {}, 'Foo';
my $foo2 = bless {}, 'Foo';
my $bar  = bless {}, 'Bar';

ok $foo->mo->checksum;

is $foo->mo->checksum,   $foo2->mo->checksum;
isnt $foo->mo->checksum, $bar->mo->checksum;

my $ref  = { this => "is some reference" };
my $ref2 = { this => "is some reference" };
my $ref3 = [qw( this is some reference )];

ok $ref->mo->checksum;
is $ref->mo->checksum,   $ref2->mo->checksum;
isnt $ref->mo->checksum, $ref3->mo->checksum;

TODO: {
    todo_skip "No metaclass support for scalars yet", 2;

    ok 42->mo->checksum;
    isnt 42->mo->checksum, "foo"->mo->checksum;
}

done_testing();
