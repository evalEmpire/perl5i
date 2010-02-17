# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::ARRAY;
use 5.010;

use strict;
use warnings;
use autobox;

sub ARRAY::grep {
    my ( $array, $filter ) = @_;

    if ( ref $filter eq 'Regexp' ) {
        return [ CORE::grep /$filter/, @$array ];
    }

    return [ CORE::grep { $filter->($_) } @$array ];
}

1;
