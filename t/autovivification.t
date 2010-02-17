#!/usr/bin/perl -w

use perl5i::latest;

use Test::More;

# Test with a hash ref
{
    my $hash;
    my $val = $hash->{key};
    is $hash, undef, "hash ref does not autoviv";

    $val = $hash->{key1}{key2};
    is $hash, undef, "hash ref does not autoviv";
}


# And a regular hash
{
    my %hash;
    my $val = $hash{key};
    is_deeply %hash->keys, [], "hash key does not autoviv";

    $val = $hash{key1}{key2};
    is_deeply %hash->keys, [], "hash key does not autoviv";
}

done_testing();
