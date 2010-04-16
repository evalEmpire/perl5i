#!/usr/bin/perl

use perl5i::latest;

use Config;
use ExtUtils::CBuilder;
use File::Spec;

use Test::More;

my $perl5i;
my $script_dir = File::Spec->catdir("blib", "script");
for my $wrapper (qw(perl5i perl5i.bat)) {
    $perl5i = File::Spec->catfile($script_dir, $wrapper);
    last if -e $perl5i;
}

ok -e $perl5i, "perl5i command line wrapper was built";

ok system(qq[$perl5i "-Ilib" -e 1]) == 0, "  and it runs";

is `$perl5i "-Ilib" -e "say 'Hello'"`, "Hello\n", "Hello perl5i!";

like `$perl5i "-Ilib" -h`, qr/disable all warnings/, 'perl5i -h works as expected';

like `$perl5i "-Ilib" -e "\$^X->say"`, qr/perl5i/, '$^X is perl5i';

done_testing(5);
