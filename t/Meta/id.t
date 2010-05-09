#!/usr/bin/perl

use perl5i::latest;

use Test::More;

sub id_ok {
    state $seen = {};

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # Use the alias to the object so strings and numbers are not copied.
    my $class   = $_[0]->mc->class;
    my $id      = $_[0]->mo->id;

    my $ok = 1;
    $ok &&= ok $id,               "$class has an id";
    $ok &&= ok !$seen->{$id}++,   "  its unique";

    return $id;
}

# Double up everything to make sure the ID is not based on content
{
    my @objs = (
        bless({}, "Foo"),
        bless({}, "Foo"),
        qr/foo/,
        qr/foo/,
        sub { 42 },
        sub { 42 },
        \"string",
        \"string",
        ["foo"],
        ["foo"],
        42,
        42,
        "string",
        "string",
    );

    for my $obj (@objs) {
        my $id = id_ok( $obj );
        is $obj->mo->id, $id, "  second call the same";
    }
}


# Test that the id is independent of content
{
    my $thing = 42;
    my $id = $thing->mo->id;
    $thing = 23;
    is $thing->mo->id, $id, "ID remains the same for a scalar with changed content";
}

{
    my $obj = bless {}, "Foo";
    my $id = $obj->mo->id;
    $obj->{key} = "value";
    is $obj->mo->id, $id, "ID remains the same even if an object's contents change";
}


done_testing();
