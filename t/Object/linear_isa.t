#!/usr/bin/perl

use perl5i::latest;
use Test::More;

is_deeply [Object->linear_isa],       ["Object"];
is_deeply [UNIVERSAL->linear_isa],    ["UNIVERSAL", "Object"];
is_deeply [DoesNotExist->linear_isa], [qw(DoesNotExist UNIVERSAL Object)];

# Set up a good ol diamond inheritance.
{
    package Child;
    use perl5i::latest;
    our @ISA = qw(Mom Dad);

    package Mom;
    our @ISA = qw(GrandParents);

    package Dad;
    our @ISA = qw(GrandParents);

    package GrandParents;
}

is_deeply [Mom->linear_isa],   [qw(Mom GrandParents UNIVERSAL Object)];
is_deeply [Child->linear_isa], [qw(Child Mom Dad GrandParents UNIVERSAL Object)]
  or diag explain( [Child->linear_isa] );

done_testing();
