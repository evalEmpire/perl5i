# vi: set ts=4 sw=4 ht=4 et :
package NUMBER;

use strict;
use warnings;
use Carp;
use Module::Load;
use POSIX qw{ceil floor};

sub SCALAR::ceil  { ceil(shift) }
sub SCALAR::floor { floor(shift)}

sub SCALAR::is_number       { shift !~ /\D/ }
sub SCALAR::is_whole_number { shift =~ /^\d+$/ }
sub SCALAR::is_integer      { shift =~ /^[+-]?\d+$/ }
sub SCALAR::is_int          { SCALAR::is_integer(shift) }
sub SCALAR::is_real_number  { shift =~ /^-?\d+\.?\d*$/ }
sub SCALAR::is_real         { SCALAR::is_integer(shift) }
sub SCALAR::is_decimal      { shift =~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/ }
sub SCALAR::is_dec          { SCALAR::is_decimal(shift) }
sub SCALAR::is_float        { shift =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/ }




1;
