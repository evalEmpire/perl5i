use strict;
use warnings;
use Test::More 0.96 tests => 4;
use perl5i::latest;

subtest 'list context' => sub {
    plan tests => 3;
    my $thing = 'hello';
    my @list = list($thing);

    is $thing, 'hello', q{The universe didn't implode};
    isa_ok \@list, 'ARRAY', q{list returns array};
    is_deeply \@list, [$thing], q{list turned the thing into a list!};
};

subtest 'scalar context' => sub {
    plan tests => 2;
    my $thing = 'hello';
    my $list_thing = list $thing;

    like $list_thing, qr/\d/, q{in scalar context, returns array size};
    is $list_thing, scalar @{[$thing]}, q{returns the right array size};
};

subtest 'all together now' => sub {
    plan tests => 1;
    my $thing = 'hello';
    my $scalar_list = scalar list $thing;
    is $scalar_list, 1, 'scalar list $thing is the size';
};

subtest 'list list' => sub {
    plan tests => 2;
    my @list = qw(one two three);

    my @stuff = list @list;
    is_deeply \@stuff, \@list, 'using list on a list gives you a list';

    my $thing = list @list;
    is_deeply $thing, scalar @list, 'force scalar context, even with list';
};
