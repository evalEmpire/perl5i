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


my $Universal = (bless {}, "UNIVERSAL")->mo->methods;

note "methods of a class with no parent"; {
    my $class = "My::Parent";

    my $want = [@$Universal, qw(parent1 parent2)];

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

    my $want = [@$Universal, qw(child1 child2 parent1 parent2)];

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


done_testing;
