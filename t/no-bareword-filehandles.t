use Test::More tests => 4;

open IN, '<', __FILE__;
ok(IN, 'bareword filehandle opened OK');

open my $in, '<', __FILE__;
ok($in, 'lexical filehandle opened OK');

use perl5i::latest;
try {
    open IN2, '<', __FILE__;
}
catch {
    like($_, qr{\QCan't use string ("IN2") as a symbol ref while "strict refs" in use},
        q{Can't use bareword filehandles with perl5i in scope});
};
open my $in2, '<', __FILE__;
ok($in2, 'lexical filehandle opened OK');
