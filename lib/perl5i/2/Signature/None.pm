package perl5i::2::Signature::None;

use strict;
use warnings;

use overload
  q[""] => sub { return $_[0]->as_string },
  q[bool] => sub { 1 },  # always true, regardless of the actual signature string
  fallback => 1
;

sub new {
    my $class = shift;
    my %args = @_;
    return bless { signature => $args{signature} }, $class;
}

sub num_params { 0 }
sub params { return []; }
sub make_real {}

sub as_string {
    my $self = shift;
    return $self->{signature};
}

1;
