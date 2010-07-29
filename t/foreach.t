#!/usr/bin/perl

use perl5i::latest;

use Test::More;

# Subroutine, no signature
{
    my @result;
    my @array = (1,2,3,4);
    @array->foreach(sub { push @result, $_[0] });

    is_deeply \@result, [1,2,3,4];
}


# Subroutine with signature
{
   my @result;
   my @array = (1,2,3,4);
   @array->foreach(func($a,$b) { push @result, $a.$b });

   is_deeply \@result, ["12","34"];
}


# Subroutine with signature, wrong scale of arguments
# XXX Should this die?
{
   my @result;
   my @array = (1,2,3,4,5);
   @array->foreach(func($a,$b) {
       $b //= '';
       push @result, $a.$b
   });

   is_deeply \@result, ["12","34", "5"];
}


# Subroutine that takes no arguments
{
   my @result;
   my @array = (1,2,3,4,5);
   ok !eval { @array->foreach(func() {}); 1 };
   is $@, sprintf "Function passed to foreach takes no arguments at %s line %d\n",
                  __FILE__, __LINE__-2;
}

done_testing;
