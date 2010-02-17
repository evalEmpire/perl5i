#!perl

use Test::More 'no_plan';
use perl5i::latest;


ok( []->is_array);
ok(!{}->is_array);
ok(!q{}->is_array);

is_deeply(
   [ [1,2,3]->flat ],
   [ 1,2,3 ],
);

is_deeply(
   [ [1,[[[2],[3]]]]->flat ],
   [ 1,2,3 ],
);

is_deeply(
   [ {1=>[[[{2=>3}]]]}->flat ],
   [ 1,2,3 ],
);

