#!/usr/bin/env perl
use perl5i::latest;
use Test::Most;

is_deeply scalar([qw{AAA BBB 123}]->transpose) # uses wantarray
        , [qw{AB1 AB2 AB3}]
        , q{array transpose works with strings};

is_deeply scalar([[qw{A A A}],[qw{B B B}], [qw{1 2 3}]]->transpose)
        , [qw{AB1 AB2 AB3}]
        , q{array transpose works with arrays};

is_deeply scalar([qw{AAA BB C 1234}]->transpose)
        , ['ABC1', 'AB 2', 'A  3', '   4']
        , q{array transpose works with unmaptched strings};

is_deeply scalar([qw{AAA BB C 1234}]->transpose('_'))
        , ['ABC1', 'AB_2', 'A__3', '___4']
        , q{array transpose works with unmaptched strings};

is_deeply scalar([ [[qw{F O O}], "BAR", "BAZ"]
                 , [1, 2, 3]
                 , ["A", "B", "C"]
                 ]),
        , [ [["F", "O", "O"], 1, "A"]
          , ["BAR", 2, "B"]
          , ["BAZ", 3, "C"]
          ]
        , q{ are references handled? https://github.com/schwern/perl5i/pull/242#issuecomment-15318379 };


done_testing;
