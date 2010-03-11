#!/usr/bin/env perl

use Test::More;
use perl5i::latest;
use Scalar::Util 'refaddr';
use Test::Exception;

my $foo  = bless {}, 'Foo';
my $foo2 = bless {}, 'Foo';
my $bar  = bless {}, 'Bar';

ok $foo->mo->checksum;

is $foo->mo->checksum,   $foo2->mo->checksum;
isnt $foo->mo->checksum, $bar->mo->checksum;

throws_ok { $foo->mo->checksum( algorithm => 'foo' ) } qr/^algorithm must be/;
throws_ok { $foo->mo->checksum( format    => 'foo' ) } qr/^format must be/;

my %digests;

my @formats = qw(hex base64 binary);
my @algos   = qw(md5 sha1);
my @refs    = ( $foo, $foo2, $bar );

foreach my $algorithm (@algos) {
    foreach my $format (@formats) {
        foreach my $ref (@refs) {
            $digests{ refaddr $ref }{$format}{$algorithm}
              = $digests{$format}{$algorithm}{ refaddr $ref }
              = $ref->mo->checksum( algorithm => $algorithm, format => $format );
        }
    }
}

# All checksums of equivalent objects should be identical
is_deeply( [ $digests{ refaddr $foo} ], [ $digests{ refaddr $foo2 } ] );

my %length = (
    binary => { md5 => 16, sha1 => 20 },
    base64 => { md5 => 22, sha1 => 27 },
    hex    => { md5 => 32, sha1 => 40 },
);

# Checksums should have the expected character length
# (this is mostly to test we're passing the options correctly)
foreach my $algorithm (@algos) {
    foreach my $format (@formats) {
        is( length $_, $length{$format}{$algorithm} ) for values %{ $digests{$format}{$algorithm} };
    }
}

# Method should work fine with non-blessed references and scalars
my $ref  = { this => "is some reference" };
my $ref2 = { this => "is some reference" };
my $ref3 = [qw( this is some reference )];

ok $ref->mo->checksum;
is $ref->mo->checksum,   $ref2->mo->checksum;
isnt $ref->mo->checksum, $ref3->mo->checksum;

ok 42->mo->checksum;
isnt 42->mo->checksum, "foo"->mo->checksum;

done_testing();
