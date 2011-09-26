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

my $child = $CLASS->new( sub {
    my $self = shift;
    $self->say( "Have self" );
    $self->say( "parent: " . $self->pid );
    my $in = $self->read();
    $self->say( $in );
}, pipe => 1 );

my $proc = $child->start;
is( $proc->read(), "Have self\n", "child has self" );
is( $proc->read(), "parent: $$\n", "child has parent PID" );
{
    local $SIG{ALRM} = sub { die "non-blocking timeout" };
    alarm 5;
    ok( !$proc->is_complete, "Not Complete" );
    alarm 0;
}
$proc->say("XXX");
is( $proc->read(), "XXX\n", "Full IPC" );
ok( $proc->wait, "wait" );
ok( $proc->is_complete, "Complete" );
is( $proc->exit_status, 0, "Exit clean" );

$proc = $CLASS->new( sub { sleep 15 } )->start;

my $ret = eval { $proc->say("XXX"); 1 };
ok( !$ret, "Died, no IPC" );
like( $@, qr/Child was created without IPC support./, "No IPC" );
if ( $^O eq 'MSWin32' ) {
    diag( "on win32 we must wait on this process (15 seconds)" );
    $proc->wait;
}
else {
    $proc->kill(2);
}

$proc = $CLASS->new( sub {
    my $self = shift;
    $SIG{INT} = sub { exit( 2 ) };
    $self->say( "go" );
    sleep 15;
    exit 2;
}, pipe => 1 )->start;

$proc->read;
sleep 1;

if ( $^O eq 'MSWin32' ) {
    diag( "on win32 we must wait on this process (15 seconds)" );
    $proc->wait;
}
else {
    ok( $proc->kill(2), "Send signal" );
    ok( !$proc->wait, "wait" );
}
ok( $proc->is_complete, "Complete" );
is( $proc->exit_status, 2, "Exit 2" );
ok( $proc->unix_exit > 2, "Real exit" );

$child = $CLASS->new( sub {
    my $self = shift;
    $self->autoflush(0);
    $self->say( "A" );
    $self->flush;
    $self->say( "B" );
    sleep 5;
    $self->flush;
}, pipe => 1 );

$proc = $child->start;
is( $proc->read(), "A\n", "A" );
my $start = time;
is( $proc->read(), "B\n", "B" );
my $end = time;

ok( $end - $start > 2, "No autoflush" );

SKIP: {
    if ($^O eq 'MSWin32') {
        skip "detach is not available on win32", 1;
    }
    else {
        $proc = $CLASS->new( sub {
            my $self = shift;
            $self->detach;
            $self->say( $self->detached );
        }, pipe => 1 )->start;
        is( $proc->read(), $proc->pid . "\n", "Child detached" );
    }
}

done_testing;
