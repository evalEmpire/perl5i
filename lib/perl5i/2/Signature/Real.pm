package perl5i::2::Signature::Real;
use perl5i::2;

use overload
  q[""] => sub { return $_[0]->{proto} },
  fallback => 1
;

method new($class: %args) {
    bless \%args, $class;
}

sub make_real () {}

method __parse_prototype {
    my $proto = $self->{proto}->trim;
    
    if( $proto =~ s{^ (\$\w+) : \s*}{}x ) {
        $self->{invocant} = $1 // '';
    }
    elsif( $self->is_method ) {
        $self->{invocant} = '$self';
    }
    else {
        $self->{invocant} = '';
    }

    my @args = split /\s*,\s*/, $proto;

    $self->{params}     = \@args;
    $self->{num_params} = @args;
}

method num_params() {
    return $self->{num_params};
}

method params() {
    return $self->{params};
}

method proto() {
    return $self->{proto};
}

method invocant() {
    return $self->{invocant};
}

method is_method() {
    return $self->{is_method};
}

1;
