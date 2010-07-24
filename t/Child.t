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

{
    my $proc = child( sub { 1 });
    ok( !$proc->ipc, "no ipc by default" );
}

{
    my $proc = child( sub { 1 }, pipe => 1 );
    ok( $proc->ipc, "ipc by param" );
}

{
    my $proc = child {
        my $parent = shift;
        $parent->say( "Have parent" );
        $parent->say( "parent: " . $parent->pid );
        my $in = $parent->read(1);
        $parent->say( $in );
    } pipe => 1;

    is( $proc->read(1), "Have parent\n", "child has parent" );
    is( $proc->read(1), "parent: $$\n", "child has parent PID" );

    {
        local $SIG{ALRM} = sub { die "non-blocking timeout" };
        alarm 5;
        ok( !$proc->is_complete, "Not Complete" );
        alarm 0;
    }
    $proc->say("XXX");
    is( $proc->read(1), "XXX\n", "Full IPC" );
    ok( $proc->wait, "wait" );
    ok( $proc->is_complete, "Complete" );
    is( $proc->exit_status, 0, "Exit clean" );
}

{
    my $proc = child {
        $SIG{INT} = sub { exit( 2 ) };
        sleep 100;
    };
    sleep 1;

    my $ret = eval { $proc->say("XXX"); 1 };
    ok( !$ret, "Died, no IPC" );
    like( $@, qr/Child was created without IPC support./, "No IPC" );

    ok( $proc->kill(2), "Send signal" );
    ok( !$proc->wait, "wait" );
    ok( $proc->is_complete, "Complete" );
    is( $proc->exit_status, 2, "Exit 2" );
    cmp_ok( $proc->unix_exit, '>', 2, "Real exit" );
}

done_testing;
