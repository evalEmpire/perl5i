#!/usr/bin/perl

use perl5i::latest;

use Test::More;
use Test::Exception;


# Test some simple symetrical conversions
{
    my %mod2path = (
        CGI                 => "CGI.pm",
        "File::Spec"        => "File/Spec.pm",
        "A::B::C"           => "A/B/C.pm",
    );

    for my $mod (keys %mod2path) {
        my $path = $mod2path{$mod};

        is $mod->module2path, $path;
        is $path->path2module, $mod;
    }
}


# Invalid module paths
{
    my @bad_paths = (
        "/foo/bar/baz.pm",
        "Not/A/Module",
        "Foo/Bar/Baz.pm/",
    );

    for my $path (@bad_paths) {
        throws_ok { $path->path2module } qr/^'$path' does not look like a Perl module path/;
    }
}


done_testing();
