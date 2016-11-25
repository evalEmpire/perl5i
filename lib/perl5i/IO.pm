package perl5i::IO;

use strict;
use warnings;

use IO::All;
use IO::All::LWP;


# This is IO::All->new but with most of the magic
# stripped out.
sub safer_io {
    my $name = shift;

    # No name, return an empty io() object.
    return io() unless defined $name;

    # Its an IO::All object, return it.
    return $name if UNIVERSAL::isa($name, 'IO::All');

    my $io = io();

    # Its a filehandle
    return $io->handle($name)
      if UNIVERSAL::isa($name, 'GLOB') or ref(\ $name) eq 'GLOB';

    # link is first because a link to a dir returns true for
    # both -l and -d.
    return $io->link($name)    if -l $name;
    return $io->file($name)    if -f $name;
    return $io->dir($name)     if -d $name;

    # Maybe its a file they're going to write to later
    $io->name($name);
    return $io;
}


{
    package IO::All;

    use strict;
    use warnings;

    sub url {
        my $self = shift;
        my $url  = shift;
    
        my($method) = $url =~ /^([a-z]+):/;
        $method ||= "http";
        $method = "file_url" if $method eq 'file';
    
        #    $self->can($scheme) or
        #      croak "url() does not know how to open scheme type $scheme";

        return $self->$method($url);
    }
}


{
    package IO::All::FILE_URL;

    # Convince IO::All that we exist
    $INC{"IO/All/FILE_URL.pm"} = 1;

    use strict;
    use warnings;

    use IO::All::LWP "-base";

    const type => "file";

    sub file_url {
        my $self = shift;

        return $self->lwp_init(__PACKAGE__, @_);
    }
}


1;
