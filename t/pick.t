 #!/usr/bin/perl
 
 use perl5i::latest;
 use Test::More;
 
 note 'pick method'; {
     my @array = qw(a b c d e f g h i);
     my @rand = @array->pick(5);
     my $size = @rand;
     is $size, 5;
     @rand = @array->pick(100);
     $size = @rand;
     is $size, 9;
     @rand = @array->pick(0);
     $size=@rand;
     is $size, 0;
}
 
 done_testing(3);
