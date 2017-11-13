package perl5i::2::MethodInfo;

use strict;
use warnings;
use 5.010_000;
use perl5i::2::autobox;
use overload '""' => sub { shift->{name} }, fallback => 1;

sub new {
    my ($this_class, $that_class, $meth, $stashelem) = @_;
    return bless { name      => $meth,
                   package   => $that_class,
                   stashelem => $stashelem }, $this_class;
}

# Delegate these methods to the CODE autobox class.
for my $method (qw( is_constant )) {
    no strict 'refs';
    *$method = sub {
        my $self = shift;
        my $sub = ref $self->{stashelem} eq 'GLOB'
            ? *{$self->{stashelem}}{CODE}
            : *{"$self->{package}:\:$self->{name}"}{CODE}; # reify
        $sub->$method
    }
}

1;
