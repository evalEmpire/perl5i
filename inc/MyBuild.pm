package MyBuild;

use base 'Module::Build';

# Override default 'build' action
# to allow compilation of perl5i.c
sub ACTION_build {
    my $self = shift;

    my ($obj_file, $exe_file);
    eval {
        my $b = $self->cbuilder();
        $obj_file = $b->compile(
            source               => 'bin/perl5i.c',
            extra_compiler_flags => '-std=c99'
        );
        $exe_file = $b->link_executable(objects => $obj_file);
    };
    if ($@) {
        print STDERR "Error: No C compiler available; please install ExtUtils::CBuilder\n";
    }

    $self->add_to_cleanup($obj_file, $exe_file);

    # Invoke parent 'build' action
    $self->SUPER::ACTION_build();
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
