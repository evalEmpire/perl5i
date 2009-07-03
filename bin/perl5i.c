#include <unistd.h>
#include <stdlib.h>

/*
 * Meant to mimic the shell command
 *     exec perl -Mperl5i "$@"
 */

int main (int argc, char* argv[]) {
    int i;
    char* perl_cmd = "perl";
    char** perl_args = malloc(sizeof(char*) * (argc + 1));
    perl_args[0] = "perl5i";
    perl_args[1] = "-Mperl5i";

    for( i = 1;  i < argc;  i++ ) {
        perl_args[i+1] = argv[i];
    }

    return execvp( perl_cmd, perl_args );
}
