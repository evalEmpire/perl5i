#!perl

use perl5i;
use Test::More tests => 21;

use IPC::Open3;

sub run_code {
    my $code = shift;

    #work around for open3 wierdness surrounding lexical filehandles
    #and stderr, $err must be true or stderr will go to stdout
    my $err = 1; 
    my $pid = open3 my $in, my $out, $err, $^X, "-Mblib", "-Mperl5i"
        or die "could not execute $^X: $!";

    print $in $code;
    close $in;
    waitpid $pid, 0;
    my $rc    = $? >> 8;
    my $output = join '', <$out>;
    my $error  = join '', <$err>;
    return ($rc, $output, $error);
}

sub test {
    my ($code, $error, $test) = @_;
    my ($rc, $out, $err) = run_code $code;
    is $rc,  255,    "$test exit code";
    is $out, "",     "$test stdout";
    is $err, $error, "$test stderr";
}

test 'die "a noble death"',                        "a noble death at - line 1.\n", 'normal die';
test 'die "a noble death\n"',                      "a noble death\n",              'die without line';
test '$! = 5; die "a noble death\n"',              "a noble death\n",              'die with $! = 5';
test '$! = 0; $? = 5 << 8; die "a noble death\n"', "a noble death\n",              'die with $! = 0 and $? = 5';
test '$! = 6; $? = 5 << 8; die "a noble death\n"', "a noble death\n",              'die with $! = 6 and $? = 5';

eval { die "oops\n" };
is $@, "oops\n", "die in block eval";

eval { die 1 .. 9, "\n" };
is $@, "123456789\n", "die in block eval with multiple arguments";

{
    my $error;
    local $SIG{__DIE__} = sub { $error = join '', @_ };
    eval { die "trigger\n" };
    is $error, "trigger\n", "__DIE__ signal handler";
}

test 'package Foo; die "a noble death\n"',         "a noble death\n",              'die in a different package';
