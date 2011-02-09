package MyBuild;

use 5.010;
use base 'Module::Build';

# Override default 'code' action
# to allow compilation of perl5i.c
sub ACTION_code {
    my $self = shift;

    # This has to be run first so the PL files are run to generate
    # the C code for us to compile.
    $self->process_PL_files;

    if ( $self->is_windowsish ) {
        # Writing a C wrapper is too hard on Windows
        # Don't need it as there's no #! anyway
        # Just do a bat file
        $self->script_files("bin/perl5i.bat");
    }
    elsif ( $self->have_c_compiler() ) {
        my $b = $self->cbuilder();

        my $obj_file = $b->compile(
            source               => 'bin/perl5i.c',
        );
        my $exe_file = $b->link_executable(objects => $obj_file);

        # script_files is set here as the resulting compiled
        # executable name varies based on operating system
        $self->script_files($exe_file);

        # Cleanup files from compilation
        $self->add_to_cleanup($obj_file, $exe_file);
    }
    else {
        # No C compiler, Unix style operating system.
        # Just use the Perl wrapper.
        File::Copy::copy("bin/perl5i.plx", "bin/perl5i");

        $self->script_files("bin/perl5i");
        $self->add_to_cleanup("bin/perl5i");
    }

    return $self->SUPER::ACTION_code;
}


# Run perltidy over all the Perl code
# Borrowed from Test::Harness
sub ACTION_tidy {
    my $self = shift;

    my %found_files = map { %$_ } $self->find_pm_files,
      $self->_find_file_by_type( 'pm', 't' ),
      $self->_find_file_by_type( 'pm', 'inc' ),
      $self->_find_file_by_type( 't',  't' ),
      $self->_find_file_by_type( 'PL', '.' );

    my @files = ( keys %found_files, map { $self->localize_file_path($_) } @extra );


    print "Running perltidy on @{[ scalar @files ]} files...\n";
    for my $file ( sort { $a cmp $b } @files ) {
        print "  $file\n";
        system( 'perltidy', '-b', $file );
        unlink("$file.bak") if $? == 0;
    }
}

sub ACTION_critic {
    my $self = shift;

    my @files = keys %{ $self->find_pm_files };

    print "Running perlcritic on @{[ scalar @files ]} files...\n";
    system( "perlcritic", @files );
}

# Check if the built in local/gmtime work for a reasonable set of
# time.  Some systems fail at 2**47 or beyond, and a lot fail at year
# 0, so those are good boundaries.
# This allows us to avoid depending on Time::y2038 which is a bit
# unreliable.
sub needs_y2038 {
    my $self = shift;

    state $limits = {
        # time             year
        2**47-1         => 4461763,
        -62135510400    => 1,
    };

    for my $time (keys %$limits) {
        my $year = $limits->{$time};

        return 1 if (gmtime($time))[5]    + 1900 != $year;
        return 1 if (localtime($time))[5] + 1900 != $year;
    }

    return 0;
}

# Build.PL creates its own MYMETA.yml because YAML::Tiny fails to parse the
# delivered one correctly. This change to the data affects how MYMETA.yml
# is created and makes sure it does so in a way that the resulting YAML
# file will properly recognize true as the dependency, and not 1.

sub write_metafile {
    my $self = shift;
    my ($metafile, $node) = @_;

    my $true_version = delete $node->{requires}{true};
    if ( $true_version ) {
        $node->{requires}{"'true'"} = $true_version;
    }

    return $self->SUPER::write_metafile( $metafile, $node );
}

1;
