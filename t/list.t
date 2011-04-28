use strict;
use warnings;
use Test::More;
use perl5i::latest;

note 'list context'; {
    my $thing = 'hello';
    my @list = list($thing);

    is $thing, 'hello', q{The universe didn't implode};
    isa_ok \@list, 'ARRAY', q{list returns array};
    is_deeply \@list, [$thing], q{list turned the thing into a list!};
}

note 'scalar context'; {
    my $thing = 'hello';
    my $list_thing = list $thing;

    like $list_thing, qr/\d/, q{in scalar context, returns array size};
    is $list_thing, scalar @{[$thing]}, q{returns the right array size};
}

note 'all together now'; {
    my $thing = 'hello';
    my $scalar_list = scalar list $thing;
    is $scalar_list, 1, 'scalar list $thing is the size';
};

note 'list list'; {
    my @list = qw(one two three);

    my @stuff = list @list;
    is_deeply \@stuff, \@list, 'using list on a list gives you a list';

    my $thing = list @list;
    is_deeply $thing, scalar @list, 'force scalar context, even with list';
}

note 'wantarray'; {
    my $code = sub { ok( wantarray, "list triggers wantarray" ); };

    list $code->();
}

done_testing;
