 #!/usr/bin/perl
 
use lib 't/lib';
use perl5i::latest;
use Test::More;
use Test::perl5i;

func pick_ok($array, $num) {
    my @rand = $array->pick($num);
    if($num <= @$array){
        is @rand, $num;
    }else{
        is @rand, @$array;
    }
    my %arr_hash = @$array->as_hash;
    foreach (@$array){
        $arr_hash{$_} += 1;
    }
    my %rand_hash = @rand->as_hash;
    my %expected_hash;
    foreach (@$array){
        if(exists $rand_hash{$_}){
            $rand_hash{$_} += 1;
            $expected_hash{$_} = $arr_hash{$_};
        }
    }
    is_deeply \%rand_hash, \%expected_hash;
}

func pick_one_ok($array){
    isa_ok(\@$array->pick_one, "SCALAR");
    my $elem = @$array->pick_one;
    my %hash = @$array->as_hash;
    my $in_arr = exists $hash{$elem};
    is $in_arr, 1;
}

note 'pick method'; {
    my @arr = qw(a b c d e f g h i);
    pick_ok(\@arr, 5);
    pick_ok(\@arr, 9);
    pick_ok(\@arr, 100);
    pick_ok(\@arr, 0);
}

note 'pick with undefined elements';{
    my $x;
    my $y;
    my $z;
    my @arr = ($x, $y, $z);
    throws_ok { @arr->pick(3); }
      qr{^\Qpick() does not allow undefined elements in the array };

}

note 'pick method with duplicate elements';{
    my @arr = (1, 1, 2, 2, 3, 3);
    pick_ok(\@arr, 6);
}

note "pick with no args"; {
    my @array = (1, 2, 3);
    throws_ok { @array->pick(); }
      qr{^\Qpick() takes the number of elements to pick at $0 line };
}

note "pick with negative arg"; {
    my @array = (1, 2, 3);
    throws_ok { @array->pick(-20); }
      qr{^\Qpick() takes a positive integer or zero, not '-20' at $0 line };
}   

note "pick with non-numerical argument"; {
    my @array = (1, 2, 3);
    throws_ok { @array->pick("rawr"); }
    qr{^\Qpick() takes a positive integer or zero, not 'rawr' at $0 line };
}

note "pick_one method";{
    my @array = (1,2,3);
    pick_one_ok(\@array);
    @array = ("a","b","c");
    pick_one_ok(\@array);
    #my $x = undef;
    #my $y = undef;
    #@array = ($x, $y);
    #pick_one_ok(\@array);
}
 
done_testing;
