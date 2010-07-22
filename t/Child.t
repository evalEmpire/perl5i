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
    my $child = child( sub { 1 });
    ok( !$child->ipc, "no ipc by default" );
}

{
    my $child = child( sub { 1 }, pipe => 1 );
    ok( $child->ipc, "ipc by param" );
}

{
    my $child = $CLASS->new( sub {
        my $self = shift;
        $self->say( "Have self" );
        $self->say( "parent: " . $self->parent );
        my $in = $self->read(1);
        $self->say( $in );
    }, pipe => 1 );

    $child->start;
    is( $child->read(1), "Have self\n", "child has self" );
    is( $child->read(1), "parent: $$\n", "child has parent PID" );

    {
        local $SIG{ALRM} = sub { die "non-blocking timeout" };
        alarm 5;
        ok( !$child->is_complete, "Not Complete" );
        alarm 0;
    }
    $child->say("XXX");
    is( $child->read(1), "XXX\n", "Full IPC" );
    ok( $child->wait, "wait" );
    ok( $child->is_complete, "Complete" );
    is( $child->exit_status, 0, "Exit clean" );
}

{
    my $child = $CLASS->new( sub {
        $SIG{INT} = sub { exit( 2 ) };
        sleep 100;
    })->start;

    ok( $child->kill(2), "Send signal" );
    ok( !$child->wait, "wait" );
    ok( $child->is_complete, "Complete" );

    TODO: {
        local $TODO = 'exit status is coming out as 0';
        is( $child->exit_status, 2, "Exit 2" );
        cmp_ok( $child->unix_exit, ">", 2, "Real exit" );
    }
}

done_testing;
