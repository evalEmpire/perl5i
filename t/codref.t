#!/usr/bin/perl
use strict;
use warnings;

use perl5i::latest;
use Test::More;

# Note, do not let the line number for these subs change!
sub foo { 1 }
my $foo2 = sub { 1 };
method a_method {
    print "1";
    print "2";
}
func a_func {
    print "1";
    print "2";
}

my $code = __PACKAGE__->can('foo');

is( $code->original_name,    'foo',  "Can get original name" );
is( $code->original_package, 'main', "Can get original package" );
is( $code->start_line,       9,      "Can get start line" );
is( $code->end_line,         undef,  "No end line set" );

$code = $foo2;
is( $code->original_name,    '__ANON__', "Can get original name (has none)" );
is( $code->original_package, 'main',     "Can get original package" );
is( $code->start_line,       10,         "Can get start line" );
is( $code->end_line,         undef,      "No end line set" );

$code = __PACKAGE__->can('a_method');
is( $code->original_name,    'a_method', "Can get original name" );
is( $code->original_package, 'main',     "Can get original package" );
is( $code->start_line,       11,         "Can get start line" );
is( $code->end_line,         14,         "Can get end line" );

$code = __PACKAGE__->can('a_func');
is( $code->original_name,    'a_func', "Can get original name" );
is( $code->original_package, 'main',   "Can get original package" );
is( $code->start_line,       16,       "Can get start line (or first statement line)" );
is( $code->end_line,         18,       "Can get end line" );

done_testing;
