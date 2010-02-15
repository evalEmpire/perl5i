#!/usr/bin/perl

use perl5i::latest;
use Test::More;

is_deeply [UNIVERSAL->mo->linear_isa],    ["UNIVERSAL"];
is_deeply [DoesNotExist->mo->linear_isa], [qw(DoesNotExist UNIVERSAL)];

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

is_deeply [Mom->mo->linear_isa],   [qw(Mom GrandParents UNIVERSAL)];
is_deeply [Child->mo->linear_isa], [qw(Child Mom Dad GrandParents UNIVERSAL)]
  or diag explain( [Child->mo->linear_isa] );

done_testing();
