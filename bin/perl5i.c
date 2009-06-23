
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, char** argv) {

	/*
	 * Meant to mimic the following shell command
	 *     exec %s -Mperl5i "$@"	
	 */
	char* perlcmd = "perl -Mperl5i";
	char* cmd = (char *)malloc( strlen(perlcmd) + 1);
	strcpy(cmd, perlcmd);

	for ( int i=1; i < argc; i++ ) {
		void** tmpaddr;
		/*
		 * one byte for trailing null,
		 * one byte for pre-pended space,
		 * two bytes for quotes
		 */
		tmpaddr = realloc( cmd, strlen(argv[i]) + 4 );
		strcat( cmd, " \"");
		strcat( cmd, argv[i] );
		strcat( cmd, "\" ");
	}

	system(cmd);
	return(0);
}

