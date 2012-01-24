 #!/usr/bin/perl
 
use lib 't/lib';
use perl5i::latest;
use Test::More;
use Test::perl5i;

func pick_ok($array, $num) {
    local $Test::Builder::Level = $Test::Builder::Level +1;
    my @rand = $array->pick($num);
    if($num <= @$array){
        is @rand, $num;
    }
    else{
        is @rand, @$array;
    }
    ok (is_subset($array, \@rand)) or diag sprintf <<END, explain $array, explain \@rand;
set: %s
subset: %s
END
}

func is_subset($array, $sub){
    my %arr_hash;
    for my $val (@$array){
        $val = safe_key($val);
        $arr_hash{$val}++;
    }
    for my $val (@$sub){
        $val = safe_key($val);
        $arr_hash{$val}--;
        return 0 if $arr_hash{$val} < 0;
    }
    return 1;
}

func pick_one_ok($array){
    local $Test::Builder::Level = $Test::Builder::Level +1;
    my $elem = @$array->pick_one;
    ok grep safe_key($_) eq safe_key($elem), @$array;
}

func safe_key($val){
    return defined $val ? $val : "__UNDEFINED__";
}

note 'is_subset';{
    ok !(is_subset([1,2,3,4] , [1,1,1]));
    
    ok !(is_subset([1,1,1,1] , [1,2]));
    
    ok is_subset([1,2,3,4] , [1,2]);
}
note 'pick()'; {
    my @arr = qw(a b c d e f g h i);
    pick_ok(\@arr, 5);
    
    pick_ok(\@arr, 9);
    
    pick_ok(\@arr, 100);
    
    pick_ok(\@arr, 0);
}

note 'pick with undefined elements';{
    pick_ok([undef,undef,undef] => 2);

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

note "pick shuffles the result"; {
    my $not_in_order = 0;
    my @array = (1..10);

    # Since @array is in ascending order, we should, eventually,
    # get two picks where the first is larger than the second.
    # There's a 50/50 chance for each pick, and with 1000 tries
    # the odds of this failing are something like 1 in 1^300.
    for(1..1000) {
        my @picks = @array->pick(2);
        next if $picks[0] < $picks[1];

        $not_in_order = 1;
        last;
    }

    ok $not_in_order;
}
 
done_testing;
