#!/usr/bin/perl

use perl5i::latest;
use Test::More;

is_deeply [UNIVERSAL->mc->linear_isa],    ["UNIVERSAL"];
is_deeply [DoesNotExist->mc->linear_isa], [qw(DoesNotExist UNIVERSAL)];

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

is_deeply [Mom->mc->linear_isa],   [qw(Mom GrandParents UNIVERSAL)];
is_deeply [Child->mc->linear_isa], [qw(Child Mom Dad GrandParents UNIVERSAL)]
  or diag explain( [Child->mc->linear_isa] );

is_deeply scalar Mom->mc->linear_isa, [qw(Mom GrandParents UNIVERSAL)], "scalar context";

done_testing();
