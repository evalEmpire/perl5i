#!perl -w

# perl5i should have lexical effect, ideally

use Test::More 'no_plan';

# use perl5i::latest in a narrow lexical scope.
# It shouldn't effect the rest of the program.
{ use perl5i::latest }


# lexical strict
{
    ok eval q{$bar = 42};
}


# lexical File::stat?
TODO: {
    local $TODO = "lexical File::stat";

    my $stat = stat("MANIFEST");
    ok !ref $stat;
}


# lexical autodie?
{
    ok eval { open my $fh, "dlkfjal;kdj"; 1 } or diag $@;
}


# lexical autovivification
{
    my $hash;
    my $val = $hash->{key};
    is_deeply $hash, {}, "no autovivification is lexical";
}


# lexical autobox
{
    my $thing = [];
    ok !eval { []->isa("ARRAY"); };
}


# lexical no indirect
{
    package Some::Thing;
    sub method { 42 }
    ::is( method Some::Thing, 42 );
}
