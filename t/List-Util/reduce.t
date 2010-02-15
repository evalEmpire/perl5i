#!perl

use perl5i::latest;

use Test::More tests => 20;

my $v = []->reduce( sub { } );

is( $v, undef, 'no args' );

$v = [ 756, 3, 7, 4 ]->reduce( sub { $a / $b } );
is( $v, 9, '4-arg divide' );

$v = [6]->reduce( sub { $a / $b } );
is( $v, 6, 'one arg' );

my @a = map { rand } 0 .. 20;
$v = @a->reduce( sub { $a < $b ? $a : $b } );
is( $v, @a->min, 'min' );

@a = map { pack( "C", int( rand(256) ) ) } 0 .. 20;
$v = @a->reduce( sub { $a . $b } );
is( $v, join( "", @a ), 'concat' );

sub add {
    my( $aa, $bb ) = @_;
    return $aa + $bb;
}

$v = [ 3, 2, 1 ]->reduce( sub { my $t = "$a $b\n"; 0 + add( $a, $b ) } );
is( $v, 6, 'call sub' );

# Check that eval{} inside the block works correctly
$v = [ 0, 1, 2, 3, 4 ]->reduce(
    sub {
        eval { die };
        $a + $b;
    }
);
is( $v, 10, 'use eval{}' );

$v = !defined eval {
    [ 0 .. 4 ]->reduce( sub { die if $b > 2; $a + $b } );
};
ok( $v, 'die' );

sub foobar {
    [ 0 .. 3 ]->reduce( sub { ( defined(wantarray) && !wantarray ) ? $a + 1 : 0 } );
}
($v) = foobar();
is( $v, 3, 'scalar context' );

sub add2 { $a + $b }

$v = [ 1, 2, 3 ]->reduce( \&add2 );
is( $v, 6, 'sub reference' );

$v = [ 3, 4, 5 ]->reduce( sub { add2() } );
is( $v, 12, 'call sub' );


$v = [ 1, 2, 3 ]->reduce( sub { eval "$a + $b" } );
is( $v, 6, 'eval string' );

$a = 8;
$b = 9;
$v = [ 1, 2, 3 ]->reduce( sub { $a * $b } );
is( $a, 8, 'restore $a' );
is( $b, 9, 'restore $b' );


# Can we leave the sub with 'return'?
$v = [ 2, 4, 6 ]->reduce( sub { return $a + $b } );
is( $v, 12, 'return' );

# ... even in a loop?
$v = [ 2, 4, 6 ]->reduce(
    sub {
        while(1) { return $a + $b }
    }
);
is( $v, 12, 'return from loop' );


# Does it work from another package?
# FIXME: this doesn't work
#{
#       package Foo;
#       $a = $b;
#       ::is([1..4]->reduce( sub {$a*$b} ), 24, 'other package');
#}


# Can we undefine a reduce sub while it's running?
sub self_immolate { undef &self_immolate; 1 }
eval { $v = [ 1, 2 ]->reduce( \&self_immolate ) };
like( $@, qr/^Can't undef active subroutine/, "undef active sub" );

# Redefining an active sub should not fail, but whether the
# redefinition takes effect immediately depends on whether we're
# running the Perl or XS implementation.

{
    my $warn;
    local $SIG{__WARN__} = sub { $warn = shift };

    sub self_updating {
        local $^W;
        *self_updating = sub { 1 };
        1;
    }
    my $l = "line " . ( __LINE__ - 3 ) . ".\n";
    eval { $v = [ 1, 2 ]->reduce( \&self_updating ) };
    is( $@, '', 'redefine self' );
    is( $warn, "Subroutine main::self_updating redefined at $0 $l" );
}

{
    my $failed = 0;

    sub rec {
        # No arg means we're being called by reduce()
        return 1 unless @_;

        my $n = shift;

        if( $n < 5 ) {
            rec( $n + 1 );
        }
        else {
            $v = [ 1, 2 ]->reduce( \&rec );
        }

        $failed = 1 if !defined $n;
    }

    rec(1);
    ok( !$failed, 'from active sub' );
}

