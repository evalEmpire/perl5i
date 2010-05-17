#!/usr/bin/perl

use perl5i::latest;

use Config;
use ExtUtils::CBuilder;
use File::Spec;
use File::Temp qw(tempfile);

use Test::More;

my $perl5i;
my $script_dir = File::Spec->catdir("blib", "script");
for my $wrapper (qw(perl5i perl5i.bat)) {
    $perl5i = File::Spec->catfile($script_dir, $wrapper);
    last if -e $perl5i;
}
my $perl5icmd = qq[$perl5i "-Ilib"];

ok -e $perl5i, "perl5i command line wrapper was built";

ok system(qq[$perl5icmd -e 1]) == 0, "  and it runs";

is `$perl5icmd -e "say 'Hello'"`, "Hello\n", "Hello perl5i!";

like `$perl5icmd -h`, qr/disable all warnings/, 'perl5i -h works as expected';

like `$perl5icmd -e "\$^X->say"`, qr/perl5i/, '$^X is perl5i';

is `$perl5icmd -wle "print 'Hello'"`, "Hello\n", "compound -e";

is `$perl5icmd -Minteger -e "say 'Hello'"`, "Hello\n", "not fooled by -Module";

# Make sure it thinks its a one liner.
is `$perl5icmd -e 'print \$0'`, "-e",      '$0 preserved';
is `$perl5icmd -e 'print __LINE__'`, 1,    '__LINE__ preserved';
is `$perl5icmd -e 'print __FILE__'`, "-e", '__FILE__ preserved';

# Check it takes code from STDIN
{
    use IPC::Open2;
    my($out, $in);
    ok open2( $out, $in, $perl5icmd ), "open2";
    print $in q[say "Hello"];
    close $in;

    is <$out>, "Hello\n", "reads code from stdin";
}

# And from a file
{
    my($fh, $file) = tempfile;
    print $fh "say 'Hello';";
    close $fh;

    is `$perl5icmd $file`, "Hello\n", "program in a file";
}

done_testing(13);
