 #!/usr/bin/perl
 
use lib 't/lib';
use perl5i::latest;
use Test::More;
use Test::perl5i;

func pick_ok($array, $num) {
    my @rand = $array->pick($num);
    if($num <= @$array){
        is @rand, $num;
    }
    else{
        is @rand, @$array;
    }
    ok is_subset($array, \@rand);
}

func is_subset($array, $sub){
    my %arr_hash;
    for my $val (@$array){
        $arr_hash{$val}++;
    }
    for my $val (@$sub){
        $arr_hash{$val}--;
        return 0 if $arr_hash{$val} < 0;
    }
    return 1;
}

func pick_one_ok($array){
    my $elem = @$array->pick_one;
    ok @$array->as_hash->{$elem};
}

note 'is_subset';{
    ok !(is_subset([1,2,3,4] , [1,1,1]));
    
    ok !(is_subset([1,1,1,1] , [1,2]));
    
    ok is_subset([1,2,3,4] , [1,2]);
}
note 'pick()'; {
    my @arr = qw(a b c d e f g h i);
    ok pick_ok(\@arr, 5);
    
    ok pick_ok(\@arr, 9);
    
    ok pick_ok(\@arr, 100);
    
    ok pick_ok(\@arr, 0);
}

note 'pick with undefined elements';{
    ok pick_ok([undef,undef,undef] => 2);

}

note 'pick method with duplicate elements';{
    pick_ok([1,1,2,2,3,3] => 6);
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
    pick_one_ok([1,2,3,4,4]);
        
    pick_one_ok(["a","b","c","d","e"]);
    
    pick_one_ok([undef, undef, undef, undef]);
}
 
done_testing;
