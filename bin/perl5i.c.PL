# Write out the perl5i wrapper C program making sure it uses
# the Perl its built with.

my $file = shift;

# Its going inside double quotes.
my $perl_path = $^X;
$perl_path =~ s{ ([\\"]) }{\\$1}gx;

open my $fh, ">", $file or die $!;
printf $fh <<'END', $perl_path, '%s';
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
 * Meant to mimic the shell command
 *     exec perl -Mperl5i "$@"
 *
 * This is a C program so it works in a #! line.
 */

int main (int argc, char* argv[]) {
    int i;
    const char* perl_cmd = "%s";
    char* perl_args[argc+1];
    perl_args[0] = argv[0];
    perl_args[1] = "-Mperl5i";

    for( i = 1;  i < argc;  i++ ) {
        #if defined(WIN32)
            char* wrapped_arg = (char *)malloc( strlen(argv[i]) + 3 );
            sprintf(wrapped_arg, "\"%s\"\0", argv[i]);
            perl_args[i+1] = wrapped_arg;
        #else
            perl_args[i+1] = argv[i];
        #endif
    }

    /* Argument array to execv must
     * terminated by a null pointer
     */
    perl_args[argc+1] = (char *)NULL;

    return execv( perl_cmd, perl_args );
}
END
