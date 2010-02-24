#!perl

use perl5i::latest;

use Test::More tests => 14;

my $v = [ 9, 4, 5, 6 ]->first( sub { 8 == ( $_ - 1 ) } );

is( $v, 9, 'one more than 8' );

$v = [ 1, 2, 3, 4 ]->first( sub { 0 } );
is( $v, undef, 'none match' );

$v = []->first( sub { 0 } );
is( $v, undef, 'no args' );

$v = [ [qw(a b c)], [qw(d e f)], [qw(g h i)] ]->first( sub { $_->[1] le "e" and "e" le $_->[2] } );
is_deeply( $v, [qw(d e f)], 'reference args' );

# Check that eval{} inside the block works correctly
my $i = 0;
$v = [ 0, 1, 2, 3, 4, 5, 5 ]->first(
    sub {
        eval { die };
        ( $i == 5, $i = $_ )[0];
    }
);
is( $v, 5, 'use of eval' );

$v = eval {
    [ 0, 0, 1 ]->first( sub { die if $_ } );
};
is( $v, undef, 'use of die' );

sub foobar {
    [ "not ", "not ", "not " ]->first( sub { !defined(wantarray) || wantarray } );
}

($v) = foobar();
is( $v, undef, 'wantarray' );

# Can we leave the sub with 'return'?
$v = [ 2, 4, 6, 12 ]->first( sub { return( $_ > 6 ) } );
is( $v, 12, 'return' );

# ... even in a loop?
$v = [ 2, 4, 6, 12 ]->first(
    sub {
        while(1) { return( $_ > 6 ) }
    }
);
is( $v, 12, 'return from loop' );

# Does it work from another package?
{

    package Foo;
    use autobox::List::Util;
    ::is( [ 1 .. 4, 24 ]->first( sub { $_ > 4 } ), 24, 'other package' );
}

# Can we undefine a first sub while it's running?
sub self_immolate { undef &self_immolate; 1 }
eval { $v = [ 1, 2 ]->first( \&self_immolate ) };
like( $@, qr/^Can't undef active subroutine/, "undef active sub" );

# Redefining an active sub should not fail, but whether the
# redefinition takes effect immediately depends on whether we're
# running the Perl or XS implementation.

{

    sub self_updating {
        no warnings 'redefine';
        *self_updating = sub { 1 };
        return;
    }
    eval { $v = [ 1, 2 ]->first( \&self_updating ) };
    is( $@, '', 'redefine self' );
}

{
    my $failed = 0;

    sub rec {
        my $n = shift;
        if( !defined($n) ) {    # No arg means we're being called by first()
            return 1;
        }
        if( $n < 5 ) { rec( $n + 1 ); }
        else { $v = [ 1, 2 ]->first( \&rec ) }
        $failed = 1 if !defined $n;
    }

    rec(1);
    ok( !$failed, 'from active sub' );
}

# Works with Regexp

is [ qw(foo bar baz) ]->first(qr/^ba/), 'bar', "Works with Regexp";
