#!/usr/bin/perl

use perl5i::latest;
use Test::More;
use Test::Exception;

{
    package Child;
    our @ISA = qw(Parent);

    sub bar {
        my $self = shift;
        $self->mo->super("super", @_);
    }

    # Watch out!  An eval BLOCK will show up in caller().
    sub with_eval {
        my $self = shift;
        return eval { $self->mo->super("super", @_) };
    }
}

{
    package Parent;
    our @ISA = qw(GrandParent);

    sub bar {
        my $self = shift;
        return $self->mo->super(@_);
    }

    sub with_eval {
        my $self = shift;
        return $self->mo->super(@_);
    }
}


# Have a grand parent to make sure we dont' just keep looping
{
    package GrandParent;

    sub new {
        my $class = shift;
        return bless {}, $class;
    }

    sub bar {
        my $self = shift;
        return "bar: @_";
    }

    sub with_eval {
        my $self = shift;
        return "with_eval: @_";
    }
}


# Try the basics
{
    my $obj = Child->new;
    is $obj->bar(), "bar: super";
    is $obj->bar(23, 42), "bar: super 23 42";

    is $obj->with_eval(), "with_eval: super";
    is $obj->with_eval(23, 42), "with_eval: super 23 42";
}


# What happens when called outside a method?
{
    my $obj = Child->new;
    ok !eval { $obj->mo->super(); };
    is $@, sprintf "super() called outside a method at $0 line %d\n", __LINE__ - 1;
}


# How about inside an unrelated class?
{
    package NotAGrandparent;
    sub bar { "wibble" }

    package NotAParent;
    our @ISA = qw(NotAGrandparent);
    sub bar {
        my $obj = Child->new;
        return $obj->mo->super(42);
    }

    package main;

    ok !eval { NotAParent->bar; };
    is $@, sprintf qq["NotAParent" is not a parent class of "Child" at $0 line %d\n], __LINE__ - 6;
}


done_testing();
