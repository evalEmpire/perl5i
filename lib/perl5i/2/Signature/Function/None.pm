package perl5i::2::Signature::Function::None;

use strict;
use warnings;

use parent 'perl5i::2::Signature::None';

sub invocant  { return '' }
sub is_method { return 0 }

1;
