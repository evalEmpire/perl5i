package Test::perl5i;

use strict;
use warnings;

use Test::More;

use base qw(Exporter);
our @EXPORT = qw(throws_ok dies_ok lives_ok);

# This is a replacement for Test::Exception which messes with caller()
# and screws up Carp.
# See http://www.xray.mpe.mpg.de/mailing-lists/perl5-porters/2010-03/msg00520.html
# Could use Test::Exception::LessClever but that's not testing on Windows
sub throws_ok(&$) {
    my($code, $regex) = @_;
    my $lived = eval { $code->(); 1 };
    if( $lived ) {
        fail;
        diag("It lived when it should have died");
    }
    my $tb = Test::More->builder;
    return $tb->like($@, $regex);
}

sub dies_ok(&;$) {
    my($code, $name) = @_;
    my $lived = eval { $code->(); 1 };

    my $tb = Test::More->builder;
    $tb->ok( !$lived, $name );
}

sub lives_ok(&;$) {
    my($code, $name) = @_;
    my $lived = eval { $code->(); 1 };

    my $tb = Test::More->builder;
    $tb->ok( $lived, $name );
}

1;
