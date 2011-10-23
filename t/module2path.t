#!/usr/bin/perl

use perl5i::latest;

use lib 't/lib';
use Test::More;
use Test::perl5i;


note "Test some simple symetrical conversions"; {
    my %mod2path = (
        CGI                 => "CGI.pm",
        "File::Spec"        => "File/Spec.pm",
        "A::B::C"           => "A/B/C.pm",
        "å::1::2"           => "å/1/2.pm",
    );

    for my $mod (keys %mod2path) {
        my $path = $mod2path{$mod};

        is $mod->module2path, $path;
        is $path->path2module, $mod;
    }
}


note "Invalid module paths"; {
    my @bad_paths = (
        "/foo/bar/baz.pm",
        "Not/A/Module",
        "Foo/Bar/Baz.pm/",
    );

    for my $path (@bad_paths) {
        throws_ok { $path->path2module } qr/^'$path' does not look like a Perl module path/;
    }
}


note "Invalid module names"; {
    my @bad_modules = (
        "::tmp::owned",
        "f/../../owned",
        "/tmp::LOL::PWNED",
    );

    for my $module (@bad_modules) {
        throws_ok { $module->module2path } qr/^'\Q$module\E' is not a valid module name/;
    }
}

done_testing();
