package MyBuild;

use base 'Module::Build';

# Override default 'build' action
# to allow compilation of perl5i.c
sub ACTION_build {
    my $self = shift;

    # This has to be run first so the PL files are run to generate
    # the C code for us to compile.
    $self->SUPER::ACTION_build(@_);

    if ( $self->have_c_compiler() ) {
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
        warn "WARNING: No C compiler available; perl5i executable will not be installed.\n";
    }
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

1;
