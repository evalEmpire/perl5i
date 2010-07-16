package perl5i::2::Signature;

use v5.10.0;
use strict;
use warnings;

use perl5i::2::Signature::Method::None;
use perl5i::2::Signature::Function::None;

# A proxy class to hold a method's signature until its actually used.

use overload
  q[""] => sub { return $_[0]->as_string },
  fallback => 1
;


sub new {
    my $class = shift;
    my %args = @_;

    my $string = $args{signature} // '';
    my $is_method = $args{is_method} // 0;

    my $no_params = !$string || $string !~ /\S/;
    if( $no_params ) {
        return $is_method ? perl5i::2::Signature::Method::None->new( signature => $string )
                          : perl5i::2::Signature::Function::None->new( signature => $string );
    }
    else {
        return bless { signature => $string, is_method => $is_method }, $class;
    }
}

sub as_string {
    my $self = shift;
    return $self->{signature};
}

sub make_real {
    my $self = shift;

    require perl5i::2::Signature::Real;
    bless $self, "perl5i::2::Signature::Real";

    $self->__parse_signature;
}

# Upgrade to a real signature object
# and call the original method.
# This should only be called once per object.
our $AUTOLOAD;
sub AUTOLOAD {
    my($method) = reverse split /::/, $AUTOLOAD;
    return if $method eq 'DESTROY';

    my $self = $_[0];  # leave @_ alone

    # Upgrade to a real object
    $self->make_real;

    goto $self->can($method);
}

1;
