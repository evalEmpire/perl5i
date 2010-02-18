#!/usr/bin/env perl

use perl5i::latest;
use Test::More;
use Test::Exception;

my @array = qw( foo bar baz );

lives_ok { @array->grep( sub { 42 } ) } "Should accept code refs";
lives_ok { @array->grep( qr/foo/ )    } "Should accept Regexps";

is_deeply( @array->grep('foo'),         [qw( foo )],     "Works with SCALAR"     );
is_deeply( @array->grep('zar'),         [],              "Works with SCALAR"     );
is_deeply( @array->grep(qr/^ba/),       [qw( bar baz )], "Works with Regexp"     );
is_deeply( @array->grep(+{ boo => 'boy' }), [],          "Works with HASH"       );
is_deeply( @array->grep([qw(boo boy)]), [],              "Works with ARRAY"      );
is_deeply( @array->grep([qw(foo baz)]), [qw(foo baz)],   "Works with ARRAY"      );
is_deeply( @array->grep(sub { /^ba/ }), [qw( bar baz )], "... as with Code refs" );


done_testing();
