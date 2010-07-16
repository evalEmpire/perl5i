package perl5i::2::Signature::Real;
use perl5i::2;

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

    $self->{parameters}     = \@args;
    $self->{num_parameters} = @args;
}

method num_parameters() {
    return $self->{num_parameters};
}

method parameters() {
    return $self->{parameters};
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
