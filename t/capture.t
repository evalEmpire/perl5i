#!/usr/bin/env perl

use perl5i::latest;

use Test::More;

note "scalar context"; {
    is capture { print "Hello" }, "Hello";

    is capture {
        print "Hello";
        warn "you should not see this";
    }, "Hello", "stderr is silenced";
}


note "tee"; {
    my($out, $err) = capture {
        capture {
            print "out";
            warn  "err";
        } tee => 1;
    };
    is $out, "out";
    like $err, qr/^err\b/;
}


note "merge"; {
    my $out = capture {
        print "out";
        print STDERR "err";
    } merge => 1;

    is $out, "outerr";
}

done_testing;
