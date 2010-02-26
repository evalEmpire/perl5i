#!/usr/bin/env perl

use perl5i::latest;
use Test::More;
use Test::Exception;

my @array = qw( foo bar baz );
my $d;

lives_ok { @array->grep( sub { 42 } ) } "Should accept code refs";
lives_ok { @array->grep( qr/foo/ )    } "Should accept Regexps";

is_deeply( $d = @array->grep('foo'),         [qw( foo )],     "Works with SCALAR"     );
is_deeply( $d = @array->grep('zar'),         [],              "Works with SCALAR"     );
is_deeply( $d = @array->grep(qr/^ba/),       [qw( bar baz )], "Works with Regexp"     );
is_deeply( $d = @array->grep(+{ boo => 'boy' }), [],          "Works with HASH"       );
is_deeply( $d = @array->grep([qw(boo boy)]), [],              "Works with ARRAY"      );
is_deeply( $d = @array->grep([qw(foo baz)]), [qw(foo baz)],   "Works with ARRAY"      );
is_deeply( $d = @array->grep(sub { /^ba/ }), [qw( bar baz )], "... as with Code refs" );

# context
my @d = @array->grep(qr/^ba/);

is scalar @d, 2, "Returns an array in list context";

done_testing();
