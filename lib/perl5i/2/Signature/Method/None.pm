package perl5i::2::Signature::Method::None;

use strict;
use warnings;

use parent 'perl5i::2::Signature::None';

sub invocant { return '$self' }
sub is_method { return 1 }

1;
