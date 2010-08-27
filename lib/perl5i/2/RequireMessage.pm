package perl5i::2::RequireMessage;
use strict;
use warnings;

# This is the sub that displays the message
my $diesub = sub {
    my ( $sub, $mod ) = @_;
    return if $^H{perl5i};
    die( <<EOT );
Can't locate $mod in your Perl library.  You may need to install it
from CPAN or another repository.  Your library paths are:
@{[ map { "  $_\n" } grep { !ref($_) } @INC ]}
EOT
};

# This sub makes sure the die sub si always at the end of @INC.
push @INC => sub {
    return if ref($INC[-1]) && $INC[-1] == $diesub;
    @INC = grep { !(ref($_) && $_ == $diesub) } @INC;
    push @INC => $diesub;
};
push @INC => $diesub;

1;
