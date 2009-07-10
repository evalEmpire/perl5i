# vi: set ts=4 sw=4 ht=4 et :
package NUMBER;

use strict;
use warnings;
use Carp;
use Module::Load;
use POSIX qw{ceil floor};
use Scalar::Util qw{looks_like_number};

sub SCALAR::ceil  { ceil(shift) }
sub SCALAR::floor { floor(shift)}

sub SCALAR::is_number { looks_like_number(shift) }




















1;
