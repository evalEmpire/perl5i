#!/usr/bin/perl
use strict;
use warnings;

use perl5i::latest;
use Test::More;

############################################################################
# These are copied from the Child tests.
# Only the works as advertised tests are copied here, not the how it does it
# tests.
############################################################################

our $CLASS = 'Child';

can_ok( __PACKAGE__, 'child' );

my $one = child( sub { 1 });
ok( !$one->ipc, "no ipc by default" );

$one = child( sub { 1 }, pipe => 1 );
ok( $one->ipc, "ipc by param" );

$one = $CLASS->new( sub {
    my $self = shift;
    $self->say( "Have self" );
    $self->say( "parent: " . $self->parent );
    my $in = $self->read(1);
    $self->say( $in );
}, pipe => 1 );

$one->start;
is( $one->read(1), "Have self\n", "child has self" );
is( $one->read(1), "parent: $$\n", "child has parent PID" );
{
    local $SIG{ALRM} = sub { die "non-blocking timeout" };
    alarm 5;
    ok( !$one->is_complete, "Not Complete" );
    alarm 0;
}
$one->say("XXX");
is( $one->read(1), "XXX\n", "Full IPC" );
ok( $one->wait, "wait" );
ok( $one->is_complete, "Complete" );
is( $one->exit_status, 0, "Exit clean" );

$one = $CLASS->new( sub {
    $SIG{INT} = sub { exit( 2 ) };
    sleep 100;
})->start;

ok( $one->kill(2), "Send signal" );
ok( !$one->wait, "wait" );
ok( $one->is_complete, "Complete" );
is( $one->exit_status, 2, "Exit 2" );
ok( $one->unix_exit > 2, "Real exit" );

done_testing;
