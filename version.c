/*
 * version - determine the version of calc
 *
 * Copyright (C) 1999-2017  David I. Bell and Landon Curt Noll
 *
 * Primary author:  David I. Bell
 *
 * Calc is open software; you can redistribute it and/or modify it under
 * the terms of the version 2.1 of the GNU Lesser General Public License
 * as published by the Free Software Foundation.
 *
 * Calc is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU Lesser General
 * Public License for more details.
 *
 * A copy of version 2.1 of the GNU Lesser General Public License is
 * distributed with calc under the filename COPYING-LGPL.  You should have
 * received a copy with calc; if not, write to Free Software Foundation, Inc.
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * Under source code control:	1990/05/22 11:00:58
 * File existed as early as:	1990
 *
 * chongo <was here> /\oo/\	http://www.isthe.com/chongo/
 * Share and enjoy!  :-)	http://www.isthe.com/chongo/tech/comp/calc/
 */


#include <stdio.h>
#include <errno.h>
#include <string.h>

#if defined(CALC_VER)
# include <stdlib.h>
# include <unistd.h>
# define STATIC static
static char *program;
#else
# include "calc.h"
#endif

#include "have_unused.h"

#define MAJOR_VER	2	/* major library version */
#define MINOR_VER	12	/* minor library version */
#define MAJOR_PATCH	6	/* major software level under library version */
#define MINOR_PATCH	3	/* minor software level or 0 if not patched */


/*
 * calc version constants
 */
int calc_major_ver = MAJOR_VER;
int calc_minor_ver = MINOR_VER;
int calc_major_patch = MAJOR_PATCH;
int calc_minor_patch = MINOR_PATCH;


/*
 * stored version
 */
STATIC char *stored_version = NULL;	/* version formed if != NULL */


/*
 * stored license info - has a side effect of copyrighting the binary
 */
char *Copyright = "\n"
  "calc - arbitrary precision calculator\n"
  "\n"
  "Copyright (C) 1999-2017  David I. Bell, Landon Curt Noll "
  					   "and Ernest Bowen\n"
  "\n"
  "Initial author:  David I. Bell\n"
  "\n"
  "Calc is open software; you can redistribute it and/or modify it under\n"
  "the terms of the version 2.1 of the GNU Lesser General Public License\n"
  "as published by the Free Software Foundation.\n";
char *Usability = "\n"
  "Calc is distributed in the hope that it will be useful, but WITHOUT\n"
  "ANY WARRANTY; without even the implied warranty of MERCHANTABILITY\n"
  "or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU Lesser General\n"
  "Public License for more details.\n";
char *COPYING_LGPL = "\n"
  "A copy of version 2.1 of the GNU Lesser General Public License is\n"
  "distributed with calc under the filename COPYING-LGPL.  You should have\n"
  "received a copy with calc; if not, write to Free Software Foundation, Inc.\n"
  "51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.\n"
  "\n"
  "For license details use the command:\thelp copying\n"
  "The COPYING-LGPL file may be viewed with:\thelp copying-lgpl\n"
  "\n";


/*
 * version - return version string
 *
 * This function returns a malloced version string.  This version
 * string does not contain the title, just:
 *
 *		x.y.z.w
 */
char *
version(void)
{
	char verbuf[BUFSIZ+1];		/* form version string here */
	size_t len;			/* length of version string */

	/*
	 * return previously stored version if one exists
	 */
	if (stored_version) {
		return stored_version;
	}

	/*
	 * form the version buffer
	 */
	snprintf(verbuf, BUFSIZ,
	    "%d.%d.%d.%d", calc_major_ver, calc_minor_ver,
	     calc_major_patch, calc_minor_patch);

	/*
	 * save the versions string into a newly malloced buffer
	 */
	len = strlen(verbuf);
	stored_version = (char *)malloc(len+1);
	if (stored_version == NULL) {
		fprintf(stderr, "%s: cannot malloc version string\n", program);
		exit(70);
	}
	strncpy(stored_version, verbuf, len);
	stored_version[len] = '\0';	/* paranoia */

	/*
	 * return the newly malloced buffer
	 */
	return stored_version;
}


#if defined(CALC_VER)


/*
 * print_rpm_version - print just the version string, rpm style
 *
 * This function prints a version string, rpm style:
 *
 *		x.y.z.w-r
 *
 * where 'r' comes from the content of the release file.
 */
void
print_rpm_version(char *release)
{
	FILE *file;		/* open file */
	char buf[BUFSIZ+1];	/* release file buffer */
	char *p;

	/*
	 * obtain the release
	 */
	file = fopen(release, "r");
	if (file == NULL) {
		fprintf(stderr, "%s: cannot open %s: %s\n",
		    program, release, strerror(errno));
		exit(71);
	}
	buf[BUFSIZ] = '\0';
	if (fgets(buf, BUFSIZ, file) == NULL) {
		fprintf(stderr, "%s: cannot read %s: %s\n",
		    program, release, strerror(errno));
		exit(72);
	}
	p = strchr(buf, '\n');
	if (p != NULL) {
		*p = '\0';
	}

	/*
	 * form the version buffer
	 */
	printf("%d.%d.%d.%d-%s\n", calc_major_ver, calc_minor_ver,
			      calc_major_patch, calc_minor_patch, buf);
	return;
}


/*
 * print_rpm_major - print just the major part version string
 *
 * This function prints the major part version string:
 *
 *		x.y.z
 */
void
print_rpm_major(void)
{
	/*
	 * form the version buffer
	 */
	printf("%d.%d.%d\n", calc_major_ver, calc_minor_ver,
			     calc_major_patch);
	return;
}


/*
 * print_rpm_release - print just the rpm release
 *
 * This function prints the rpm release:
 *
 *		r
 *
 * where 'r' comes from the content of the release file.
 */
void
print_rpm_release(char *release)
{
	FILE *file;		/* open file */
	char buf[BUFSIZ+1];	/* release file buffer */
	char *p;

	/*
	 * obtain the release
	 */
	file = fopen(release, "r");
	if (file == NULL) {
		fprintf(stderr, "%s: cannot open %s: %s\n",
		    program, release, strerror(errno));
		exit(73);
	}
	buf[BUFSIZ] = '\0';
	if (fgets(buf, BUFSIZ, file) == NULL) {
		fprintf(stderr, "%s: cannot read %s: %s\n",
		    program, release, strerror(errno));
		exit(74);
	}
	p = strchr(buf, '\n');
	if (p != NULL) {
		*p = '\0';
	}

	/*
	 * form the version buffer
	 */
	printf("%s\n", buf);
	return;
}


/*
 * version - print the calc version
 */
/*ARGSUSED*/
int
main(int argc, char *argv[])
{
	program = argv[0];
	if (argc == 3 && strcmp(argv[1], "-r") == 0) {
		print_rpm_version(argv[2]);

	} else if (argc == 3 && strcmp(argv[1], "-R") == 0) {
		print_rpm_release(argv[2]);

	} else if (argc == 2 && strcmp(argv[1], "-V") == 0) {
		print_rpm_major();

	} else if (argc == 1) {
		printf("%s\n", version());

	} else {
		fprintf(stderr,
		    "usage: %s [-V] [-R release_file] [-r release_file]\n",
		    program);
		exit(75);
	}
	return 0;
}

#endif /* CALC_VER */
