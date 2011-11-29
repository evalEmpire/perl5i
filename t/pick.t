 #!/usr/bin/perl
 
use perl5i::latest;
use Test::More;

note 'pick method'; {
    my @array = qw(a b c d e f g h i);

    my @rand = @array->pick(5);
    is @rand, 5;

    @rand = @array->pick(100);
    is @rand, 9;

    @rand = @array->pick(0);
    is @rand, 0;
}
 
done_testing(3);
