#!/usr/bin/perl

use perl5i::latest;

use Test::More;

{
    package My::Child;

    our @ISA = qw(My::Parent);

    sub child1 {}
    sub child2 {}
    sub parent1 {}  # don't count this twice
}

{
    package My::Parent;

    sub parent1 {}
    sub parent2 {}
}

note "methods of a class with no parent"; {
    my $class = "My::Parent";

    my $want = [qw(parent1 parent2)];

    is_deeply
      scalar $class->mc->methods->sort,
      scalar $want->sort,
      "methods on a simple class";

    my $obj = bless {}, "My::Parent"; 

    is_deeply
      scalar $obj->mo->methods->sort,
      scalar $want->sort,
      "methods on a simple object";
}


note "methods of a class on a child"; {
    my $class = "My::Child";

    my $want = [qw(child1 child2 parent1 parent2)];

    is_deeply
      scalar $class->mc->methods->sort,
      scalar $want->sort,
      "inherited methods on a class";

    my $obj = bless {}, "My::Child";

    is_deeply
      scalar $obj->mo->methods->sort,
      scalar $want->sort,
      "inherited method on a class";
}


note "just_mine => 1"; {
    my $child = bless {}, "My::Child";
    my $methods = $child->mo->methods({
        just_mine => 1
    });

    is_deeply
      scalar $methods->sort,
      [sort qw(child1 child2 parent1)],
      "just_mine does not show inherited methods";
}


note "with_UNIVERSAL => 1"; {
    my $child = bless {}, "My::Child";
    my %methods = $child->mo->methods({
        with_UNIVERSAL  => 1
    })->map(sub { $_ => 1 });

    my $want = [qw(child1 child2 parent1 isa can VERSION mc mo)];
    for my $method (@$want) {
        ok $methods{$method}, "My::Child->$method";
    }
}


note "UNIVERSAL still works"; {
    # We're not sure what's going to be in UNIVERSAL
    # but we know what should be there at minimum

    my %methods = UNIVERSAL->mc->methods->map(sub { $_ => 1});

    my @min_want = qw(can isa VERSION mc mo);
    for my $method (@min_want) {
        ok $methods{$method}, "UNIVERSAL->$method";
    }
}


# Fcntl has scalar refs in its symbol table probably due to some XS wackiness
SKIP: {
    note "Weird things in the symbol table";
    skip "Need Fcntl", 1 unless eval { "Fcntl"->require };

    my @methods = Fcntl->mc->methods({ just_mine => 1 });
    can_ok "Fcntl", @methods;
}

{
    package My::MixedDefs;
    use perl5i::latest;

    sub    as_sub    {}
    func   as_func   {}
    method as_method {}
}
{
    package My::MixedDefs::Child;
    our @ISA = qw(My::MixedDefs);
    use perl5i::latest;

    sub    as_sub2    {}
    func   as_func2   {}
    method as_method2 {}
}


note "func gets filtered out of methods list"; {
    my( @methods, @expected, @not_expected );

    my $class = "My::MixedDefs";

    @methods      = $class->mc->methods;
    @expected     = qw( as_method as_sub );
    @not_expected = qw( as_func inexistant );
    is_deeply
      scalar @methods->intersect( [ @expected, @not_expected ] )->sort,
      scalar @expected->sort,
      'on a class';

    my $obj = bless {}, $class;

    @methods      = $obj->mo->methods;
    @expected     = qw( as_method as_sub );
    @not_expected = qw( as_func inexistant );
    is_deeply
      scalar @methods->intersect( [ @expected, @not_expected ] )->sort,
      scalar @expected->sort,
      'on an object';

    $class = "My::MixedDefs::Child";

    @methods      = $class->mc->methods;
    @expected     = qw( as_method as_sub as_method2 as_sub2 );
    @not_expected = qw( as_func as_func2 inexistant );
    is_deeply
      scalar @methods->intersect( [ @expected, @not_expected ] )->sort,
      scalar @expected->sort,
      'on a child class';

    $obj = bless {}, $class;

    @methods      = $obj->mo->methods;
    @expected     = qw( as_method as_sub as_method2 as_sub2 );
    @not_expected = qw( as_func as_func2 inexistant );
    is_deeply
      scalar @methods->intersect( [ @expected, @not_expected ] )->sort,
      scalar @expected->sort,
      'on a child object';

    can_ok( $class, 'as_func'); # sanity check
}

done_testing;
