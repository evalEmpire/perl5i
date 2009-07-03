#!/usr/bin/perl

use perl5i;

use Config;
use ExtUtils::CBuilder;

use Test::More;

my $builder = ExtUtils::CBuilder->new;
plan skip_all => "No C compiler, assuming command line wrapper not built"
  unless $builder->have_compiler;

my $perl5i = "./bin/perl5i".$Config{_exe};

ok -e $perl5i, "perl5i command line wrapper was built";

ok system("$perl5i -e 1") == 0, "  and it runs";

is `$perl5i -e 'say "Hello"'`, "Hello\n", "Hello perl5i!";

like `$perl5i -h`, qr/disable all warnings/, 'perl5i -h works as expected';

done_testing(4);
