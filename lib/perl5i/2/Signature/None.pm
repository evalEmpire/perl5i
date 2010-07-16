package perl5i::2::Signature::None;

use strict;
use warnings;

use overload
  q[""] => sub { return $_[0]->{proto} },
  fallback => 1
;

sub new {
    my $class = shift;
    my %args = @_;
    return bless { proto => $args{proto} }, $class;
}

sub num_params { 0 }
sub params { return []; }
sub make_real {}

sub proto {
    my $self = shift;
    return $self->{proto};
}

1;
