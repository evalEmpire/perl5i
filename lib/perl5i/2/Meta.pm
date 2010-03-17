package perl5i::2::Meta;

use strict;
use warnings;

# Be very careful not to import anything.
require Carp;
require mro;

require perl5i::2::Meta::Instance;
require perl5i::2::Meta::Class;

sub UNIVERSAL::mo {
    # Be careful to pass through an alias, not a copy
    return perl5i::2::Meta::Instance->new($_[0]);
}

sub UNIVERSAL::mc {
    return perl5i::2::Meta::Class->new($_[0]);
}

sub new {
    my $class = shift;
    # Be careful to take a reference to an alias, not a copy
    return bless \$_[0], $class;
}

sub ISA {
    my $class = $_[0]->class;

    no strict 'refs';
    return wantarray ? @{$class.'::ISA'} : \@{$class.'::ISA'};
}

sub linear_isa {
    my $self = shift;
    my $class = $self->class;

    # get_linear_isa() does not return UNIVERSAL
    my @extra;
    @extra = qw(UNIVERSAL) unless $class eq 'UNIVERSAL';

    my $isa = [@{mro::get_linear_isa($class)}, @extra];
    return wantarray ? @$isa : $isa;
}


# A single place to put the "method not found" error.
my $method_not_found = sub {
    my $class  = shift;
    my $method = shift;

    Carp::croak sprintf q[Can't locate object method "%s" via package "%s"],
      $method, $class;
};


# caller() will return if its inside an eval, need to skip over those.
my $find_method = sub {
    my $method;
    my $height = 2;
    do {
        $method = (caller($height))[3];
        $height++;
    } until( !defined $method or $method ne '(eval)' );

    return $method;
};


sub super {
    my $self = shift;
    my $class = $self->class;

    my $fq_method = $find_method->();
    Carp::croak "super() called outside a method" unless $fq_method;

    my($parent, $method) = $fq_method =~ /^(.*)::(\w+)$/;

    Carp::croak sprintf qq["%s" is not a parent class of "%s"], $parent, $class
      unless $class->isa($parent);

    my @isa = $self->linear_isa();

    while(@isa) {
        my $class = shift @isa;
        last if $class eq $parent;
    }

    for (@isa) {
        my $code = $_->can($method);
        @_ = ($$self, @_);
        goto &$code if $code;
    }

    $class->$method_not_found($method);
}

1;
