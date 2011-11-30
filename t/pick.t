 #!/usr/bin/perl
 
use perl5i::latest;
use Test::More;

note 'pick method'; {
    my @array = qw(a b c d e f g h i);

    my @rand = @array->pick(5);
    is @rand, 5;
    my %rand_hash = @array->as_hash;
    my %expected_hash;
    foreach (@array){
        if(exists $rand_hash{$_}){
            $rand_hash{$_} -= 1;
            $expected_hash{$_} = 0;
        }
    }
    is_deeply \%rand_hash, \%expected_hash;
   
    @rand = @array->pick(100);
    is @rand, 9;

    @rand = @array->pick(0);
    is @rand, 0;
}
 
done_testing(4);
