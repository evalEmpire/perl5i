/*
 * Meant to mimic the shell command
 *     exec perl -Mperl5i::latest "$@"
 *
 * This is a C program so it works in a #! line with minimal overhead.
 */

#define DEBUG 0

#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include "perl5i.h"

char *safe_cat(char *a, char*b) {
    char *new = malloc(sizeof(char) * (strlen(a) + strlen(b) + 1));

    strcpy(new, a);
    strcat(new, b);

    return new;
}

int main (int argc, char* argv[]) {
    int i;
    
    char **exec_args  = malloc(sizeof(char*) * (argc + 2));
    int num_exec_args = argc + 1;

    /* Insert -Mperl5i::cmd=... into a copy of argv */
    exec_args[0] = argv[0];
    exec_args[1] = safe_cat("-Mperl5i::cmd=", argv[0]);
    for( i = 1; i < argc; i++ ) {
        exec_args[i+1] = argv[i];
    }

    exec_args[num_exec_args] = NULL;

    execv(Perl_Path, exec_args );
    
    fprintf(stderr, "Executing %s failed: %s\n", Perl_Path, strerror(errno));
}
