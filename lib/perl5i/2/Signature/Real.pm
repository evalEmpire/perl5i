package perl5i::2::Signature::Real;
use perl5i::2;

use overload
  q[""] => sub { return $_[0]->as_string },
  fallback => 1
;

method new($class: %args) {
    bless \%args, $class;
}

sub make_real () {}

method __parse_signature {
    my $string = $self->{signature}->trim;
    
    if( $string =~ s{^ (\$\w+) : \s*}{}x ) {
        $self->{invocant} = $1 // '';
    }
    elsif( $self->is_method ) {
        $self->{invocant} = '$self';
    }
    else {
        $self->{invocant} = '';
    }

    my @args = split /\s*,\s*/, $string;

    $self->{params}     = \@args;
    $self->{positional_params} = \@args;
    $self->{num_positional_params} = @args;

    return;
}

method num_positional_params() {
    return $self->{num_positional_params};
}

method positional_params() {
    return $self->{positional_params};
}

method params() {
    return $self->{params};
}

method as_string() {
    return $self->{signature};
}

method invocant() {
    return $self->{invocant};
}

method is_method() {
    return $self->{is_method};
}

1;
