#!/usr/bin/env perl

# This is a template for writing new test files.
# In this place should be an overall description of what the test file is about.
# Test files should ideally be about one method or group of methods,
# or a single, complicated bug.
#
# See https://github.com/evalEmpire/perl5i/wiki/Coding-Standards

use perl5i::latest;
use Test::Most;

note "Describe what this block is doing, use as many blocks as you need"; {
    my $lexical = "Keep variables in narrow scopes";

    is 1+1, 2, "Addition";
}

done_testing;
