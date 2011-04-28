#!/usr/bin/perl

use perl5i::latest;

use Config;
use ExtUtils::CBuilder;
use File::Spec;
use File::Temp qw(tempdir tempfile);

use Test::More;

my $perl5i;
my $script_dir = File::Spec->catdir("blib", "script");
for my $wrapper (qw(perl5i perl5i.bat)) {
    $perl5i = File::Spec->catfile($script_dir, $wrapper);
    last if -e $perl5i;
}
my $perl5icmd = qq[$perl5i "-Ilib"];
my @perl5icmd = ($perl5i, "-Ilib");

ok -e $perl5i, "perl5i command line wrapper was built";

ok system(qq[$perl5icmd -e 1]) == 0, "  and it runs";

is capture { system @perl5icmd, "-e", "say 'Hello'" }, "Hello\n", "Hello perl5i!";

like `$perl5icmd -h`, qr/disable all warnings/, 'perl5i -h works as expected';

like capture { system @perl5icmd, "-e", '$^X->say' }, qr/perl5i/, '$^X is perl5i';

is capture { system @perl5icmd, '-wle', q[print 'Hello'] }, "Hello\n", "compound -e";

is capture { system @perl5icmd, "-Minteger", "-e", q[say 'Hello'] }, "Hello\n",
  "not fooled by -Module";

# Make sure it thinks its a one liner.
is capture { system @perl5icmd, "-e", q[print $0] },       "-e",       '$0 preserved';
is capture { system @perl5icmd, "-e", q[print __LINE__] }, 1,          '__LINE__ preserved';
is capture { system @perl5icmd, "-e", q[print __FILE__] }, "-e",       '__FILE__ preserved';

# Check it takes code from STDIN
{
    my $out = capture {
        open( my $in, "|-", $perl5icmd );
        print $in qq[say "Hello"\n];
        close $in;
    };

    is $out, "Hello\n", "reads code from stdin";
}

# And from a file
{
    my $dir = tempdir("perl5i-turd-XXXX", CLEANUP => 1, TMPDIR => 1);
    my($fh, $file) = tempfile(DIR => $dir);
    print $fh "say 'Hello';";
    close $fh;

    is `$perl5icmd $file`, "Hello\n", "program in a file";
}

# Check it doesn't have strict vars on
is capture {system @perl5icmd, '-e', q($fun="yay"; say $fun;)}, "yay\n", 'no strict vars for perl5i';
is capture {system ($^X, '-Ilib', '-Mperl5i::latest', '-e', q|$fun="yay"; say $fun;|)},
    "yay\n", q{no strict vars for perl -Mperl5i::latest -e '...'};

done_testing;
