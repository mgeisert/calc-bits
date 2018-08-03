#!/bin/make
#
# calc - arbitrary precision calculator
#
########################################################################
# Gnu makefile: # This is a Gnu make makefile.  If your make does not  #
# Gnu makefile: # understand this makefile format, then edit and use   #
# Gnu makefile: # Makefile.simple instead of this Makefile.            #
########################################################################
#
# (Generic calc makefile)
#
#  NOTE: This is NOT the calc rpm Makefile.  This Makefile is a generic
#	 Makefile for the people who build calc from the bzip2-ed tarball.
#	 Without modification, it does not assume the system has readline,
#	 ncurses or less.  It compiles with gcc -O3 -g3 as well.  You can
#	 change all this by modifying the Makefile variables below.
#
#  NOTE: You might want use the READLINE facility if  your system
#	 has the GNU readline headers and libraries:
#
#	 USE_READLINE= -DUSE_READLINE
#	 READLINE_LIB= -lreadline
#	 READLINE_EXTRAS= -lhistory -lncurses
#
# Copyright (C) 1999-2017  Landon Curt Noll
#
# Calc is open software; you can redistribute it and/or modify it under
# the terms of version 2.1 of the GNU Lesser General Public License
# as published by the Free Software Foundation.
#
# Calc is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
# Public License for more details.
#
# A copy of version 2.1 of the GNU Lesser General Public License is
# distributed with calc under the filename COPYING-LGPL.  You should have
# received a copy with calc; if not, write to Free Software Foundation, Inc.
# 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
#
MAKEFILE_REV= $$Revision: 30.88 $$
#
# Under source code control:	1990/02/15 01:48:41
# File existed as early as:	before 1990
#
# chongo <was here> /\oo/\	http://www.isthe.com/chongo/
# Share and enjoy!  :-)	http://www.isthe.com/chongo/tech/comp/calc/
#
# calculator by David I. Bell with help/mods from others
# Makefile by Landon Curt Noll

#if 0	/* start of skip for non-Gnu makefiles */
##############################################################################
#-=-=-=-=-=-=-=-=- Identify the target machine, if possible -=-=-=-=-=-=-=-=-#
##############################################################################

# NOTE: You can force a target value by defining target as in:
#
#	make ...__optional_arguments_... target=value

# Try uname -s if the target was not already set on the make command line
#
ifeq ($(target),)
target=$(shell uname -s 2>/dev/null)
endif
#endif	/* end of skip for non-Gnu makefiles */

##############################################################################
#-=-=-=-=-=-=-=-=- You may want to change some values below -=-=-=-=-=-=-=-=-#
##############################################################################

# Determine the type of terminal controls that you want to use
#
#	value		  meaning
#	--------	  -------
#	(nothing)	  let the Makefile guess at what you need
#	-DUSE_TERMIOS	  use struct termios from <termios.h>
#	-DUSE_TERMIO	  use struct termios from <termio.h>
#	-DUSE_SGTTY	  use struct sgttyb from <sys/ioctl.h>
#	-DUSE_NOTHING	  windoz system, don't use any of them
#
# Select TERMCONTROL= -DUSE_TERMIOS for DJGPP.
#
# If in doubt, leave TERMCONTROL empty.
#
TERMCONTROL=
#TERMCONTROL= -DUSE_TERMIOS
#TERMCONTROL= -DUSE_TERMIO
#TERMCONTROL= -DUSE_SGTTY
#TERMCONTROL= -DUSE_WIN32

# If your system does not have a vsprintf() function, you could be in trouble.
#
#	vsprintf(string, format, ap)
#
# This function works like sprintf except that the 3rd arg is a va_list
# strarg (or varargs) list.  Some old systems do not have vsprintf().
# If you do not have vsprintf(), then calc will try sprintf() and hope
# for the best.
#
# A similar problem occurs if your system does not have a vsnprintf()
# function.  This function is like the vsprintf() function except that
# there is an extra second argument that controls the maximum size
# string that is produced.
#
# If HAVE_VSPRINTF is empty, this Makefile will run the have_stdvs.c and/or
# have_varvs.c program to determine if vsprintf() is supported.  If
# HAVE_VSPRINTF is set to -DDONT_HAVE_VSPRINTF then calc will hope that
# sprintf() will work.
#
# If in doubt, leave HAVE_VSPRINTF empty.
#
HAVE_VSPRINTF=
#HAVE_VSPRINTF= -DDONT_HAVE_VSPRINTF

# Determine the byte order of your machine
#
#    Big Endian:	Amdahl, 68k, Pyramid, Mips, Sparc, ...
#    Little Endian:	Vax, 32k, Spim (Dec Mips), i386, i486, ...
#
# If in doubt, leave CALC_BYTE_ORDER empty.  This Makefile will attempt to
# use BYTE_ORDER in <machine/endian.h> or it will attempt to run
# the endian program.  If you get syntax errors when you compile,
# try forcing the value to be -DBIG_ENDIAN and run the calc regression
# tests. (see the README.FIRST file) If the calc regression tests fail, do
# a make clobber and try -DCALC_LITTLE_ENDIAN.   If that fails, ask a wizard
# for help.
#
# Select CALC_BYTE_ORDER= -DCALC_LITTLE_ENDIAN for DJGPP.
#
CALC_BYTE_ORDER=
#CALC_BYTE_ORDER= -DBIG_ENDIAN
#CALC_BYTE_ORDER= -DLITTLE_ENDIAN

# Determine the number of bits in a long
#
# If in doubt, leave LONG_BITS empty.  This Makefile will run
# the longbits program to determine the length.
#
# In order to avoid make brain damage in some systems, we avoid placing
# a space after the ='s below.
#
# Select LONG_BITS= 32 for DJGPP.
#
LONG_BITS=
#LONG_BITS= 32
#LONG_BITS= 64

# Determine if we have the ANSI C fgetpos and fsetpos alternate interface
# to the ftell() and fseek() (with whence set to SEEK_SET) functions.
#
# If HAVE_FPOS is empty, this Makefile will run the have_fpos program
# to determine if there is are fgetpos and fsetpos functions.  If HAVE_FPOS
# is set to -DHAVE_NO_FPOS, then calc will use ftell() and fseek().
#
# If in doubt, leave HAVE_FPOS empty and this Makefile will figure it out.
#
HAVE_FPOS=
#HAVE_FPOS= -DHAVE_NO_FPOS

# Determine if we have an __pos element of a file position (fpos_t) structure.
#
# If HAVE_FPOS_POS is empty, this Makefile will run the have_fpos_pos program
# to determine if fpos_t has a __pos structure element.  If HAVE_FPOS_POS
# is set to -DHAVE_NO_FPOS_POS, then calc assume there is no __pos element.
#
# Select HAVE_FPOS_POS= -DHAVE_NO_FPOS_POS for DJGPP.
#
# If in doubt, leave HAVE_FPOS_POS empty and this Makefile will figure it out.
#
HAVE_FPOS_POS=
#HAVE_FPOS_POS= -DHAVE_NO_FPOS_POS

# Determine the size of the __pos element in fpos_t, if it exists.
#
# If FPOS_POS_BITS is empty, then the Makefile will determine the size of
# the file position value of the __pos element.
#
# If there is no __pos element in fpos_t (say because fpos_t is a scalar),
# leave FPOS_POS_BITS blank.
#
# If in doubt, leave FPOS_POS_BITS empty and this Makefile will figure it out.
#
FPOS_POS_BITS=
#FPOS_POS_BITS= 32
#FPOS_POS_BITS= 64

# Determine the size of a file position value.
#
# If FPOS_BITS is empty, then the Makefile will determine the size of
# the file position value.
#
# Select FPOS_BITS= 32 for DJGPP.
#
# If in doubt, leave FPOS_BITS empty and this Makefile will figure it out.
#
FPOS_BITS=
#FPOS_BITS= 32
#FPOS_BITS= 64

# Determine the size of the off_t file offset element
#
# If OFF_T_BITS is empty, then the Makefile will determine the size of
# the file offset value.
#
# Select OFF_T_BITS= 32 for DJGPP.
#
# If in doubt, leave OFF_T_BITS empty and this Makefile will figure it out.
#
OFF_T_BITS=
#OFF_T_BITS= 32
#OFF_T_BITS= 64

# Determine the size of the dev_t device value
#
# If DEV_BITS is empty, then the Makefile will determine the size of
# the dev_t device value
#
# Select DEV_BITS= 32 for DJGPP.
#
# If in doubt, leave DEV_BITS empty and this Makefile will figure it out.
#
DEV_BITS=
#DEV_BITS= 16
#DEV_BITS= 32
#DEV_BITS= 64

# Determine the size of the ino_t device value
#
# If INODE_BITS is empty, then the Makefile will determine the size of
# the ino_t inode value
#
# Select INODE_BITS= 32 for DJGPP.
#
# If in doubt, leave INODE_BITS empty and this Makefile will figure it out.
#
INODE_BITS=
#INODE_BITS= 16
#INODE_BITS= 32
#INODE_BITS= 64

# Determine if we have an off_t which one can perform arithmetic operations,
# assignments and comparisons.  On some systems off_t is some sort of union
# or struct.
#
# If HAVE_OFFSCL is empty, this Makefile will run the have_offscl program
# to determine if off_t is a scalar.  If HAVE_OFFSCL is set to the value
# -DOFF_T_NON_SCALAR when calc will assume that off_t some sort of
# union or struct.
#
# If in doubt, leave HAVE_OFFSCL empty and this Makefile will figure it out.
#
HAVE_OFFSCL=
#HAVE_OFFSCL= -DOFF_T_NON_SCALAR

# Determine if we have an fpos_t which one can perform arithmetic operations,
# assignments and comparisons.  On some systems fpos_t is some sort of union
# or struct.  Some systems do not have an fpos_t and long is as a file
# offset instead.
#
# If HAVE_POSSCL is empty, this Makefile will run the have_offscl program
# to determine if off_t is a scalar, or if there is no off_t and long
# (a scalar) should be used instead.  If HAVE_POSSCL is set to the value
# -DFILEPOS_NON_SCALAR when calc will assume that fpos_t exists and is
# some sort of union or struct.
#
# If in doubt, leave HAVE_POSSCL empty and this Makefile will figure it out.
#
HAVE_POSSCL=
#HAVE_POSSCL= -DFILEPOS_NON_SCALAR

# Determine if we have ANSI C const.
#
# If HAVE_CONST is empty, this Makefile will run the have_const program
# to determine if const is supported.  If HAVE_CONST is set to -DHAVE_NO_CONST,
# then calc will not use const.
#
# If in doubt, leave HAVE_CONST empty and this Makefile will figure it out.
#
HAVE_CONST=
#HAVE_CONST= -DHAVE_NO_CONST

# Determine if we have uid_t
#
# If HAVE_UID_T is empty, this Makefile will run the have_uid_t program
# to determine if uid_t is supported.  If HAVE_UID_T is set to -DHAVE_NO_UID_T,
# then calc will treat uid_t as an unsigned short.  This only matters if
# $HOME is not set and calc must look up the home directory in /etc/passwd.
#
# If in doubt, leave HAVE_UID_T empty and this Makefile will figure it out.
#
HAVE_UID_T=
#HAVE_UID_T= -DHAVE_NO_UID_T

# Determine if we have memcpy(), memset() and strchr()
#
# If HAVE_NEWSTR is empty, this Makefile will run the have_newstr program
# to determine if memcpy(), memset() and strchr() are supported.  If
# HAVE_NEWSTR is set to -DHAVE_NO_NEWSTR, then calc will use bcopy() instead
# of memcpy(), use bfill() instead of memset(), and use index() instead of
# strchr().
#
# If in doubt, leave HAVE_NEWSTR empty and this Makefile will figure it out.
#
HAVE_NEWSTR=
#HAVE_NEWSTR= -DHAVE_NO_NEWSTR

# Determine if we have memmove()
#
# If HAVE_MEMMOVE is empty, this Makefile will run the have_memmv program
# to determine if memmove() is supported.  If HAVE_MEMMOVE is set to
# -DHAVE_NO_MEMMOVE, then calc will use internal functions to simulate
# the memory move function that does correct overlapping memory moves.
#
# If in doubt, leave HAVE_MEMMOVE empty and this Makefile will figure it out.
#
HAVE_MEMMOVE=
#HAVE_MEMMOVE= -DHAVE_NO_MEMMOVE

# Determine if we have ustat()
#
# If HAVE_USTAT is empty, this Makefile will run the have_ustat program
# to determine if ustat() is supported.  If HAVE_USTAT is set to
# -DHAVE_NO_USTAT, then calc will use internal functions to simulate
# the ustat() function that gets file system statistics.
#
# Select HAVE_USTAT= -DHAVE_NO_USTAT for DJGPP.
#
# If in doubt, leave HAVE_USTAT empty and this Makefile will figure it out.
#
HAVE_USTAT=
#HAVE_USTAT= -DHAVE_NO_USTAT

# Determine if we have getsid()
#
# If HAVE_GETSID is empty, this Makefile will run the have_getsid program
# to determine if getsid() is supported.  If HAVE_GETSID is set to
# -DHAVE_NO_GETSID, then calc will use internal functions to simulate
# the getsid() function that gets session ID.
#
# Select HAVE_GETSID= -DHAVE_NO_GETSID for DJGPP.
#
# If in doubt, leave HAVE_GETSID empty and this Makefile will figure it out.
#
HAVE_GETSID=
#HAVE_GETSID= -DHAVE_NO_GETSID

# Determine if we have getpgid()
#
# If HAVE_GETPGID is empty, this Makefile will run the have_getpgid program
# to determine if getpgid() is supported.  If HAVE_GETPGID is set to
# -DHAVE_NO_GETPGID, then calc will use internal functions to simulate
# the getpgid() function that sets the process group ID.
#
# Select HAVE_GETPGID= -DHAVE_NO_GETPGID for DJGPP.
#
# If in doubt, leave HAVE_GETPGID empty and this Makefile will figure it out.
#
HAVE_GETPGID=
#HAVE_GETPGID= -DHAVE_NO_GETPGID

# Determine if we have clock_gettime()
#
# If HAVE_GETTIME is empty, this Makefile will run the have_gettime program
# to determine if clock_gettime() is supported.  If HAVE_GETTIME is set to
# -DHAVE_NO_GETTIME, then calc will use internal functions to simulate
# the clock_gettime() function.
#
# Select HAVE_GETTIME= -DHAVE_NO_GETTIME for DJGPP.
#
# If in doubt, leave HAVE_GETTIME empty and this Makefile will figure it out.
#
HAVE_GETTIME=
#HAVE_GETTIME= -DHAVE_NO_GETTIME

# Determine if we have getprid()
#
# If HAVE_GETPRID is empty, this Makefile will run the have_getprid program
# to determine if getprid() is supported.  If HAVE_GETPRID is set to
# -DHAVE_NO_GETPRID, then calc will use internal functions to simulate
# the getprid() function.
#
# Select HAVE_GETPRID= -DHAVE_NO_GETPRID for DJGPP.
#
# If in doubt, leave HAVE_GETPRID empty and this Makefile will figure it out.
#
HAVE_GETPRID=
#HAVE_GETPRID= -DHAVE_NO_GETPRID

# Determine if we have the /dev/urandom
#
#    HAVE_URANDOM_H=		let the Makefile look for /dev/urandom
#    HAVE_URANDOM_H= YES	assume that /dev/urandom exists
#    HAVE_URANDOM_H= NO		assume that /dev/urandom does not exist
#
# Select HAVE_URANDOM_H= NO for DJGPP.
#
# When in doubt, leave HAVE_URANDOM_H empty.
#
HAVE_URANDOM_H=
#HAVE_URANDOM_H= YES
#HAVE_URANDOM_H= NO

# Determine if we have getrusage()
#
# If HAVE_GETRUSAGE is empty, this Makefile will run the have_rusage program
# to determine if getrusage() is supported.  If HAVE_GETRUSAGE is set to
# -DHAVE_NO_GETRUSAGE, then calc will use internal functions to simulate
# the getrusage() function.
#
# If in doubt, leave HAVE_GETRUSAGE empty and this Makefile will figure it out.
#
HAVE_GETRUSAGE=
#HAVE_GETRUSAGE= -DHAVE_NO_GETRUSAGE

# Determine if we have strdup()
#
# If HAVE_STRDUP is empty, this Makefile will run the have_strdup program
# to determine if strdup() is supported.  If HAVE_STRDUP is set to
# -DHAVE_NO_STRDUP, then calc will use internal functions to simulate
# the strdup() function.
#
# If in doubt, leave HAVE_STRDUP empty and this Makefile will figure it out.
#
HAVE_STRDUP=
#HAVE_STRDUP= -DHAVE_NO_STRDUP

# Some architectures such as Sparc do not allow one to access 32 bit values
# that are not aligned on a 32 bit boundary.
#
# The Dec Alpha running OSF/1 will produce alignment error messages when
# align32.c tries to figure out if alignment is needed.  Use the
# ALIGN32= -DMUST_ALIGN32 to force alignment and avoid such error messages.
#
# ALIGN32=		     let align32.c figure out if alignment is needed
# ALIGN32= -DMUST_ALIGN32    force 32 bit alignment
# ALIGN32= -UMUST_ALIGN32    allow non-alignment of 32 bit accesses
#
# Select ALIGN32= -UMUST_ALIGN32 for DJGPP.
#
# When in doubt, be safe and pick ALIGN32=-DMUST_ALIGN32.
#
ALIGN32=
#ALIGN32= -DMUST_ALIGN32
#ALIGN32= -UMUST_ALIGN32

# Determine if we have the <stdlib.h> include file.
#
#    HAVE_STDLIB_H=		let the Makefile look for the include file
#    HAVE_STDLIB_H= YES		assume that the include file exists
#    HAVE_STDLIB_H= NO		assume that the include file does not exist
#
# Select HAVE_STDLIB_H= YES for DJGPP.
#
# When in doubt, leave HAVE_STDLIB_H empty.
#
HAVE_STDLIB_H=
#HAVE_STDLIB_H= YES
#HAVE_STDLIB_H= NO

# Determine if we have the <string.h> include file.
#
#    HAVE_STRING_H=		let the Makefile look for the include file
#    HAVE_STRING_H= YES		assume that the include file exists
#    HAVE_STRING_H= NO		assume that the include file does not exist
#
# Select HAVE_STRING_H= YES for DJGPP.
#
# When in doubt, leave HAVE_STRING_H empty.
#
HAVE_STRING_H=
#HAVE_STRING_H= YES
#HAVE_STRING_H= NO

# Determine if we have the <times.h> include file.
#
#    HAVE_TIMES_H=		let the Makefile look for the include file
#    HAVE_TIMES_H= YES		assume that the include file exists
#    HAVE_TIMES_H= NO		assume that the include file does not exist
#
# Select HAVE_TIMES_H= NO for DJGPP.
#
# When in doubt, leave HAVE_TIMES_H empty.
#
HAVE_TIMES_H=
#HAVE_TIMES_H= YES
#HAVE_TIMES_H= NO

# Determine if we have the <sys/times.h> include file.
#
#    HAVE_SYS_TIMES_H=		let the Makefile look for the include file
#    HAVE_SYS_TIMES_H= YES	assume that the include file exists
#    HAVE_SYS_TIMES_H= NO	assume that the include file does not exist
#
# Select HAVE_SYS_TIMES_H= YES for DJGPP.
#
# When in doubt, leave HAVE_SYS_TIMES_H empty.
#
HAVE_SYS_TIMES_H=
#HAVE_SYS_TIMES_H= YES
#HAVE_SYS_TIMES_H= NO

# Determine if we have the <time.h> include file.
#
#    HAVE_TIME_H=		let the Makefile look for the include file
#    HAVE_TIME_H= YES		assume that the include file exists
#    HAVE_TIME_H= NO		assume that the include file does not exist
#
# Select HAVE_TIME_H= YES for DJGPP.
#
# When in doubt, leave HAVE_TIME_H empty.
#
HAVE_TIME_H=
#HAVE_TIME_H= YES
#HAVE_TIME_H= NO

# Determine if we have the <sys/time.h> include file.
#
#    HAVE_SYS_TIME_H=		let the Makefile look for the include file
#    HAVE_SYS_TIME_H= YES	assume that the include file exists
#    HAVE_SYS_TIME_H= NO	assume that the include file does not exist
#
# Select HAVE_SYS_TIME_H= YES for DJGPP.
#
# When in doubt, leave HAVE_SYS_TIME_H empty.
#
HAVE_SYS_TIME_H=
#HAVE_SYS_TIME_H= YES
#HAVE_SYS_TIME_H= NO

# Determine if we have the <unistd.h> include file.
#
#    HAVE_UNISTD_H=		let the Makefile look for the include file
#    HAVE_UNISTD_H= YES		assume that the include file exists
#    HAVE_UNISTD_H= NO		assume that the include file does not exist
#
# Select HAVE_UNISTD_H= YES for DJGPP.
#
# When in doubt, leave HAVE_UNISTD_H empty.
#
HAVE_UNISTD_H=
#HAVE_UNISTD_H= YES
#HAVE_UNISTD_H= NO

# Determine if our compiler allows the unused attribute
#
# If HAVE_UNUSED is empty, this Makefile will run the have_unused program
# to determine if the unused attribute is supported.  If HAVE_UNUSED is set to
# -DHAVE_NO_UNUSED, then the unused attribute will not be used.
#
# Select HAVE_UNUSED= for DJGPP.
#
# If in doubt, leave HAVE_UNUSED empty and this Makefile will figure it out.
#
HAVE_UNUSED=
#HAVE_UNUSED= -DHAVE_NO_UNUSED

# System include files
#
# ${INCDIR}		where the system include (.h) files are kept
#
# For DJGPP, select:
#
#	INCDIR= /dev/env/DJDIR/include
#
# If in doubt, set:
#
#	INCDIR= /usr/include
#

#INCDIR= /usr/local/include
#INCDIR= /dev/env/DJDIR/include
INCDIR= /usr/include

# Where to install calc related things
#
# ${BINDIR}		where to install calc binary files
# ${LIBDIR}		where calc link library (*.a) files are installed
# ${CALC_SHAREDIR}	where to install calc help, .cal, startup, config files
# ${CALC_INCDIR}	where the calc include files are installed
#
# NOTE: The install rule prepends installation paths with ${T}, which
#	by default is empty.  If ${T} is non-empty, then installation
#	locations will be relative to the ${T} directory.
#
# NOTE: If you change LIBDIR to a non-standard location, you will need
#	to make changes to your execution environment so that executables
#	will search LIBDIR when they are resolving dynamic shared libraries.
#
#	On OS X, this means you need to export $DYLD_LIBRARY_PATH
#	to include the LIBDIR path in the value.
#
#	On Linux and BSD, this means you need to export $LD_LIBRARY_PATH
#	to include the LIBDIR path in the value.
#
#	You might be better off not changing LIBDIR in the first place.
#
# For DJGPP, select:
#
#	BINDIR= /dev/env/DJDIR/bin
#	LIBDIR= /dev/env/DJDIR/lib
#	CALC_SHAREDIR= /dev/env/DJDIR/share/calc
#
# If in doubt, set:
#
#	BINDIR= /usr/bin
#	LIBDIR= /usr/lib
#	CALC_SHAREDIR= /usr/share/calc
#
#BINDIR= /usr/local/bin
#BINDIR= /dev/env/DJDIR/bin
BINDIR= /usr/bin

#LIBDIR= /usr/local/lib
#LIBDIR= /dev/env/DJDIR/lib
LIBDIR= /usr/lib

#CALC_SHAREDIR= /usr/local/lib/calc
#CALC_SHAREDIR= /dev/env/DJDIR/share/calc
CALC_SHAREDIR= /usr/share/calc

# NOTE: Do not set CALC_INCDIR to /usr/include or /usr/local/include!!!
#	Always be sure that the CALC_INCDIR path ends in /calc to avoid
#	conflicts with system or other application include files!!!
#
#CALC_INCDIR= /usr/local/include/calc
#CALC_INCDIR= /dev/env/DJDIR/include/calc
CALC_INCDIR= ${INCDIR}/calc

# By default, these values are based CALC_SHAREDIR, INCDIR, BINDIR
# ---------------------------------------------------------------
# ${HELPDIR}		where the help directory is installed
# ${CUSTOMCALDIR}	where custom *.cal files are installed
# ${CUSTOMHELPDIR}	where custom help files are installed
# ${CUSTOMINCDIR}	where custom .h files are installed
# ${SCRIPTDIR}		where calc shell scripts are installed
#
# NOTE: The install rule prepends installation paths with ${T}, which
#	by default is empty.  If ${T} is non-empty, then installation
#	locations will be relative to the ${T} directory.
#
# If in doubt, set:
#
#	HELPDIR= ${CALC_SHAREDIR}/help
#	CALC_INCDIR= ${INCDIR}/calc
#	CUSTOMCALDIR= ${CALC_SHAREDIR}/custom
#	CUSTOMHELPDIR= ${CALC_SHAREDIR}/custhelp
#	CUSTOMINCDIR= ${CALC_INCDIR}/custom
#	SCRIPTDIR= ${BINDIR}/cscript
#
HELPDIR= ${CALC_SHAREDIR}/help
CUSTOMCALDIR= ${CALC_SHAREDIR}/custom
CUSTOMHELPDIR= ${CALC_SHAREDIR}/custhelp
CUSTOMINCDIR= ${CALC_INCDIR}/custom
SCRIPTDIR= ${BINDIR}/cscript

# T - top level directory under which calc will be installed
#
# The calc install is performed under ${T}, the calc build is
# performed under /.  The purpose for ${T} is to allow someone
# to install calc somewhere other than into the system area.
#
# For example, if:
#
#     BINDIR= /usr/bin
#     LIBDIR= /usr/lib
#     CALC_SHAREDIR= /usr/share/calc
#
# and if:
#
#     T= /var/tmp/testing
#
# Then the installation locations will be:
#
#     calc binary files:	/var/tmp/testing/usr/bin
#     calc link library:	/var/tmp/testing/usr/lib
#     calc help, .cal ...:	/var/tmp/testing/usr/share/calc
#     ... etc ...               /var/tmp/testing/...
#
# If ${T} is empty, calc is installed under /, which is the same
# top of tree for which it was built.  If ${T} is non-empty, then
# calc is installed under ${T}, as if one had to chroot under
# ${T} for calc to operate.
#
# If in doubt, use T=
#
T=

# where man pages are installed
#
# Select MANDIR= /dev/env/DJDIR/man/man1 for DJGPP.
#
# Use MANDIR= to disable installation of the calc man (source) page.
#
#MANDIR=
#MANDIR= /usr/local/man/man1
#MANDIR= /usr/man/man1
MANDIR= /usr/share/man/man1
#MANDIR= /dev/env/DJDIR/man/man1
#MANDIR= /usr/man/u_man/man1
#MANDIR= /usr/contrib/man/man1

# where cat (formatted man) pages are installed
#
# Select CATDIR= /dev/env/DJDIR/man/cat1 for DJGPP.
#
# Use CATDIR= to disable installation of the calc cat (formatted) page.
#
CATDIR=
#CATDIR= /usr/local/man/cat1
#CATDIR= /usr/local/catman/cat1
#CATDIR= /usr/man/cat1
#CATDIR= /usr/share/man/cat1
#CATDIR= /dev/env/DJDIR/man/cat1
#CATDIR= /var/cache/man/cat1
#CATDIR= /usr/man/u_man/cat1
#CATDIR= /usr/contrib/man/cat1

# extension to add on to the calc man page filename
#
# This is ignored if CATDIR is empty.
#
MANEXT= 1
#MANEXT= l

# extension to add on to the calc man page filename
#
# This is ignored if CATDIR is empty.
#
CATEXT= 1
#CATEXT= 1.gz
#CATEXT= 0
#CATEXT= l

# how to format a man page
#
# If CATDIR is non-empty, then
#
#     If NROFF is non-empty, then
#
#	  ${NROFF} ${NROFF_ARG} calc.1 > ${CATDIR}/calc.${CATEXT}
#	  	   is used to build and install the cat page
#
#     else (NROFF is empty)
#
#	  ${MANMAKE} calc.1 ${CATDIR}
#	  	     is used to build and install the cat page
# else
#
#     The cat page is not built or installed
#
# Select NROFF= groff for DJGPP.
#
# If in doubt and you don't want to fool with man pages, set MANDIR
# and CATDIR to empty and ignore the NROFF, NROFF_ARG and MANMAKE
# lines below.
#
#NROFF= nroff
NROFF=
#NROFF= groff
NROFF_ARG= -man
#NROFF_ARG= -mandoc
MANMAKE= /usr/local/bin/manmake
#MANMAKE= manmake
MANMODE= 0444
CATMODE= 0444

# By default, custom builtin functions may only be executed if calc
# is given the -C option.  This is because custom builtin functions
# may invoke non-standard or non-portable code.  One may completely
# disable custom builtin functions by not compiling any custom code
#
# ALLOW_CUSTOM= -DCUSTOM	# allow custom only if -C is given
# ALLOW_CUSTOM=			# disable custom even if -C is given
#
# If in doubt, use ALLOW_CUSTOM= -DCUSTOM
#
ALLOW_CUSTOM= -DCUSTOM
#ALLOW_CUSTOM=

# If the $CALCPATH environment variable is not defined, then the following
# path will be searched for calc resource file routines.
#
# Select CALCPATH= .;./cal;~/.cal;${CALC_SHAREDIR};${CUSTOMCALDIR} for DJGPP.
#
#if 0	/* start of skip for non-Gnu makefiles */
ifdef RPM_TOP
ifdef ALLOW_CUSTOM
CALCPATH= .:./cal:~/.cal:${CALC_SHAREDIR}:${CUSTOMCALDIR}
else
CALCPATH= .:./cal:~/.cal:${CALC_SHAREDIR}
endif
else
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
CALCPATH= .:./cal:~/.cal:${T}${CALC_SHAREDIR}:${T}${CUSTOMCALDIR}
#if 0	/* start of skip for non-Gnu makefiles */
else
CALCPATH= .:./cal:~/.cal:${T}${CALC_SHAREDIR}
endif
endif
#endif	/* end of skip for non-Gnu makefiles */

# If the $CALCRC environment variable is not defined, then the following
# path will be searched for calc resource files.
#
# Select CALCRC= ${CALC_SHAREDIR}/startup;~/.calcrc;./.calcinit for DJGPP.
#
CALCRC= ${CALC_SHAREDIR}/startup:~/.calcrc:./.calcinit
#CALCRC= ${CALC_SHAREDIR}/startup;~/.calcrc;./.calcinit

# Determine of the GNU-readline facility will be used instead of the
# builtin calc binding method.
#
# USE_READLINE=			    Do not use GNU-readline, use calc bindings
# USE_READLINE= -DUSE_READLINE	    Use GNU-readline, do not use calc bindings
#
# NOTE: If you select the 'USE_READLINE= -DUSE_READLINE' mode, you must set:
#
#	READLINE_LIB		The flags needed to link in the readline
#				and history link libraries
#	READLINE_EXTRAS		Flags and libs needed to use the readline
#				and history link libraries
#	READLINE_INCLUDE	Where the readline include files reside
#				(leave blank if they are /usr/include/readline)
#
# NOTE: The GNU-readline code is not shipped with calc.  You must have
#	the appropriate headers and link libs installed on your system in
#	order to use it.
#
# If in doubt, set USE_READLINE, READLINE_LIB and READLINE_INCLUDE to nothing.
#
USE_READLINE=
#USE_READLINE= -DUSE_READLINE
#
READLINE_LIB=
READLINE_EXTRAS=
#
#READLINE_LIB= -lreadline
#READLINE_EXTRAS= -lhistory -lncurses
#
#READLINE_LIB= -L/usr/gnu/lib -lreadline
#READLINE_EXTRAS= -lhistory -lncurses
#
#READLINE_LIB= -L/usr/local/lib -lreadline
#READLINE_EXTRAS= -lhistory -lncurses
#
# For Apple OS X: install fink from http://fink.sourceforge.net
#		  and then do a 'fink install readline' and then use:
#
#READLINE_LIB= -L/sw/lib -lreadline
#READLINE_EXTRAS= -lhistory -lncurses
#
# For Apple OS X: install homebrew and then:
#
#	brew install readline
#
# and use:
#
#READLINE_LIB= -L/usr/local/opt/readline/lib -lreadline
#READLINE_EXTRAS= -lhistory -lncurses
#
READLINE_INCLUDE=
#READLINE_INCLUDE= -I/usr/gnu/include
#READLINE_INCLUDE= -I/usr/local/include

# If $PAGER is not set, use this program to display a help file
#
# Select CALCPAGER= less.exe -ci for DJGPP.
#
#CALCPAGER= more
#CALCPAGER= pg
#CALCPAGER= cat
CALCPAGER= less
#CALCPAGER= less.exe -ci

# Debug/Optimize options for ${CC} and ${LCC}
#
# Select DEBUG= -O2 -gstabs+ -DWINDOZ for DJGPP.
#
#DEBUG=
#DEBUG= -g
#DEBUG= -g3
#
#DEBUG= -O
#DEBUG= -O -g
#DEBUG= -O -g3
#
#DEBUG= -O1
#DEBUG= -O1 -g
#DEBUG= -O1 -g3
#
#DEBUG= -O2
#DEBUG= -O2 -g
#DEBUG= -O2 -g3
#DEBUG= -O2 -ipa
#DEBUG= -O2 -g3 -ipa
#
#DEBUG= -O3
#DEBUG= -O3 -g
DEBUG= -O3 -g3
#DEBUG= -O3 -ipa
#DEBUG= -O3 -g3 -ipa

# Some systems require one to use ranlib to add a symbol table to
# a *.a link library.  Set RANLIB to the utility that performs this
# action.  Set RANLIB to : if your system does not need such a utility.
#
RANLIB=ranlib
#RANLIB=:

# Normally certain files depend on the Makefile.  If the Makefile is
# changed, then certain steps should be redone.  If MAKE_FILE is
# set to Makefile, then these files will depend on Makefile.  If
# MAKE_FILE is empty, then they won't.
#
# If in doubt, set MAKE_FILE to Makefile
#
MAKE_FILE= Makefile

# Controlling file makefile basename (without the path)
#
# This is the basename same of the makefile that may/does/will drive
# this makefile.
#
# If in doubt, set TOP_MAKE_FILE to Makefile
#
TOP_MAKE_FILE= Makefile

# If you do not wish to use purify, set PURIFY to an empty string.
#
# If in doubt, use PURIFY=
#
#PURIFY= purify
#PURIFY= purify -m71-engine
#PURIFY= purify -logfile=pure.out
#PURIFY= purify -m71-engine -logfile=pure.out
PURIFY=

# If you want to use a debugging link library such as a malloc debug link
# library, or need to add special ld flags after the calc link libraries
# are included, set ${LD_DEBUG} below.
#
# If in doubt, set LD_DEBUG to empty.
#
#LD_DEBUG= -lmalloc_cv
LD_DEBUG=

# When doing a:
#
#	make check
#	make chk
#	make debug
#
# the ${CALC_ENV} is used to supply the proper environment variables
# to calc.  Most people will simply need 'CALCPATH=./cal' to ensure
# that these debug rules will only use calc resource files under the
# local source directory.  The longer lines (with MALLOC_VERBOSE=1 ...)
# are useful for SGI IRIX people who have 'WorkShop Performance Tools'
# and who also set 'LD_DEBUG= -lmalloc_cv' above.
#
# If in doubt, use:
#
#	CALC_ENV= CALCPATH=./cal LD_LIBRARY_PATH=.:./custom DYLD_LIBRARY_PATH=.
#
CALC_ENV= CALCPATH=./cal LD_LIBRARY_PATH=. DYLD_LIBRARY_PATH=.
#CALC_ENV= CALCPATH=./cal DYLD_LIBRARY_PATH=. \
#	  MALLOC_VERBOSE=1 MALLOC_TRACING=1 \
#	  MALLOC_FASTCHK=1 MALLOC_FULLWARN=1 LD_LIBRARY_PATH=.:./custom
#CALC_ENV= CALCPATH=./cal DYLD_LIBRARY_PATH=. \
#	  MALLOC_VERBOSE=1 MALLOC_TRACING=1 \
#	  MALLOC_FASTCHK=1 MALLOC_FULLWARN=1 MALLOC_CLEAR_FREE=1 \
#	  MALLOC_CLEAR_MALLOC=1 LD_LIBRARY_PATH=.:./custom


# Some out of date operating systems require/want an executable to
# end with a certain file extension.  Some compiler systems such as
# windoz build calc as calc.exe.  The EXT variable is used to denote
# the extension required by such.  Note that Cygwin requires EXT to be
# the same as Linux/Un*x/GNU, even though it runs under windoz.
#
# EXT=				# normal Un*x / Linux / GNU/Linux / Cygwin
# EXT=.exe			# windoz
#
# If in doubt, use EXT=
#
EXT=
#EXT=.exe

# The default calc versions
#
VERSION= 2.12.6.3

# Names of shared libraries with versions
#
LIB_EXT= .so
LIB_EXT_VERSION= ${LIB_EXT}.${VERSION}

# standard utilities used during make
#
SHELL= /bin/sh
LANG= C
MAKE= make
AWK= awk
SED= sed
DIFF= diff
GREP= egrep
SORT= sort
TEE= tee
CTAGS= ctags
CHMOD= chmod
FMT= fmt
XARGS= xargs
CMP= cmp
MKDIR= mkdir
SPLINT= splint
SPLINT_OPTS=
RM= rm
TOUCH= touch
RMDIR= rmdir
CP= cp
MV= mv
CO= co
AR= ar
TRUE= true
CAT= cat
COL= col
LN= ln
LDCONFIG= ldconfig
# assume the X11 makedepend tool for the depend rule
MAKEDEPEND= makedepend
STRIP= strip

# Extra compiling and linking flags
#
# EXTRA_CFLAGS are flags given to ${CC} when compiling C files
# EXTRA_LDFLAGS are flags given to ${CC} when linking programs
#
# Both CFLAGS and LDFLAGS are left blank in this Makefile by
# default so that users may use them on the make command line
# to always set the way that C is compiled and files are linked
# respectively.  For example:
#
#	make all EXTRA_CFLAGS="-DMAGIC" EXTRA_LDFLAGS="-lmagic"
#
# NOTE: These should be left blank in this Makefile to make it
#       easier to add stuff on the command line.  If you want to
#	to change the way calc is compiled by this Makefile, change
#	the appropriate host target section below or a flag above.
#
EXTRA_CFLAGS=
EXTRA_LDFLAGS=

# COMMON_CFLAGS are the common ${CC} flags used for all programs, both
#	    intermediate and final calc and calc related programs
#
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
COMMON_CFLAGS= -DCALC_SRC ${ALLOW_CUSTOM} ${CCWARN} ${CCMISC} ${EXTRA_CFLAGS}
#if 0	/* start of skip for non-Gnu makefiles */
else
COMMON_CFLAGS= -DCALC_SRC -UCUSTOM ${CCWARN} ${CCMISC} ${EXTRA_CFLAGS}
endif
#endif	/* end of skip for non-Gnu makefiles */

# COMMON_LDFLAGS are the common flags used for linking all programs, both
#	     intermediate and final calc and calc related programs
#
COMMON_LDFLAGS= ${EXTRA_LDFLAGS}

# start of host target cut - Do not remove this line
##############################################################################
#-=-=-=-=-=- host target section - targets that override defaults -=-=-=-=-=-#
##############################################################################

# Common values set in targets
#
# BLD_TYPE determines if calc is built with static and/or dynamic libs.
#	       Set this value to one of:
#
#	BLD_TYPE= calc-dynamic-only
#	BLD_TYPE= calc-static-only
#
# CC_SHARE are flags given to ${CC} to build .o files suitable for shared libs
# DEFAULT_LIB_INSTALL_PATH is where calc programs look for calc shared libs
# LD_SHARE are common flags given to ${CC} to link with shared libraries
# LIBCALC_SHLIB are flags given to ${CC} to build libcalc shared libraries
# LIBCUSTCALC_SHLIB are flags given to ${CC} to build libcustcalc shared lib
#
#	NOTE: The above 5 values are unused if BLD_TYPE= calc-static-only
#
# CC_STATIC are flags given to ${CC} to build .o files suitable for static libs
# LD_STATIC are common flags given to ${CC} to link with static libraries
# LIBCALC_STATIC are flags given to ${CC} to build libcalc static libraries
# LIBCUSTCALC_STATIC are flags given to ${CC} to build libcustcalc static lib
#
#	NOTE: The above 4 values are unused if BLD_TYPE= calc-dynamic-only
#
# CCOPT are flags given to ${CC} for optimization
# CCWARN are flags given to ${CC} for warning message control
#
# WNO_IMPLICT, WNO_ERROR_LONG_LONG and WNO_LONG_LONG are given to ${CC}
#	when compiling special .o files that may need special compile options
#	NOTE: These flags simply turn off certain compiler warnings,
#	      which is useful only when CCWERR is set to -Werror.
#	NOTE: If your compiler does not have these -Wno files, just
#	      set these variables to nothing as in:
#		WNO_IMPLICT=
#		WNO_ERROR_LONG_LONG=
#		WNO_LONG_LONG=
#
# CCWERR are flags given to ${CC} to make warnings fatal errors
#	NOTE: CCWERR is only set in development Makefiles and must only be
#	      used with ${CC}, not ${LCC}.  If you do not want the compiler
#	      to abort on warnings, then leave CCWERR blank.
# CCMISC are misc flags given to ${CC}
#
# LCC is how the C compiler is invoked on locally executed intermediate programs
# CC is how the C compiler is invoked (with an optional Purify)
#
# Specific target overrides or modifications to default values

##########################################################################
# NOTE: If your target is not supported below and the default target	 #
#	is not suitable for your needs, please send to the:		 #
#									 #
#		calc-contrib at asthe dot com				 #
#									 #
#	EMail address an "ifeq ($(target),YOUR_TARGET_NAME)" ... "endif" #
#	set of lines so that we can consider them for the next release.  #
##########################################################################

#if 0	/* start of skip for non-Gnu makefiles */
################
# Linux target #
################

ifeq ($(target),Linux)
#
BLD_TYPE= calc-dynamic-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LD_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use gcc's -Werror to force warnings
# to become errors, call make with:
#
#   make .. COMMON_ADD='-Werror'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
endif

##############################
# Apple OS X / Darwin target #
##############################

ifeq ($(target),Darwin)
#
BLD_TYPE= calc-dynamic-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:${LIBDIR}:/usr/local/lib
LD_SHARE= ${DARWIN_ARCH}
#SET_INSTALL_NAME= no
SET_INSTALL_NAME= yes
ifeq ($(SET_INSTALL_NAME),yes)
LIBCALC_SHLIB= -single_module -undefined dynamic_lookup -dynamiclib \
    -install_name ${LIBDIR}/libcalc${LIB_EXT_VERSION} ${DARWIN_ARCH}
else
LIBCALC_SHLIB= -single_module -undefined dynamic_lookup -dynamiclib \
    ${DARWIN_ARCH}
endif
ifdef ALLOW_CUSTOM
ifeq ($(SET_INSTALL_NAME),yes)
LIBCUSTCALC_SHLIB= -single_module -undefined dynamic_lookup -dynamiclib \
    -install_name ${LIBDIR}/libcustcalc${LIB_EXT_VERSION} ${DARWIN_ARCH}
else
LIBCUSTCALC_SHLIB= -single_module -undefined dynamic_lookup -dynamiclib \
    ${DARWIN_ARCH}
endif
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LD_STATIC= ${DARWIN_ARCH}
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use clang's -fsanitize for calc testing,
# which requires a common set of flags to be passed to
# every compile and link, then call make with:
#
#   make .. COMMON_ADD='-fsanitize=undefined -fsanitize=address'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC= ${DARWIN_ARCH}
#
LCC= clang
CC= ${PURIFY} ${LCC} ${CCWERR}
#
# Darwin dynamic shared lib filenames
LIB_EXT:= .dylib
LIB_EXT_VERSION:= .${VERSION}${LIB_EXT}
# LDCONFIG not required on this platform, so we redefine it to an empty string
LDCONFIG:=
# DARWIN_ARCH= -arch i386 -arch ppc	# Universal binary
# DARWIN_ARCH= -arch i386		# Intel binary
# DARWIN_ARCH= -arch ppc		# PPC binary
# DARWIN_ARCH= -arch x86_64		# native 64-bit binary
DARWIN_ARCH=				# native binary
#
# Starting with El Capitan OS X 10.11, root by default could not
# mkdir under system locations, so we now use the /usr/local tree.
#
OPTDIR:= /usr/local
BINDIR:= /${OPTDIR}/bin
LIBDIR:= /${OPTDIR}/lib
CALC_SHAREDIR:= /${OPTDIR}/share
CALC_INCDIR:= /${OPTDIR}/include
SCRIPTDIR:= ${BINDIR}/cscript
endif

##################
# FreeBSD target #
##################

########################################################################
# NOTE: You MUST either use gmake (GNU Make) or you must try your luck #
#       with Makefile.simple and custom/Makefile.simple versions.      #
#	See HOWTO.INSTALL for more information.                        #
########################################################################

ifeq ($(target),FreeBSD)
#
BLD_TYPE= calc-dynamic-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LD_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use gcc's -Werror to force warnings
# to become errors, call make with:
#
#   make .. COMMON_ADD='-Werror'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
MAKE= gmake
#
endif

##################
# OpenBSD target #
##################

########################################################################
# NOTE: You MUST either use gmake (GNU Make) or you must try your luck #
#       with Makefile.simple and custom/Makefile.simple versions.      #
#	See HOWTO.INSTALL for more information.                        #
########################################################################

ifeq ($(target),OpenBSD)
#
BLD_TYPE= calc-dynamic-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LD_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use gcc's -Werror to force warnings
# to become errors, call make with:
#
#   make .. COMMON_ADD='-Werror'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
MAKE= gmake
#
endif

################
# SunOS target #
################

ifeq ($(target),SunOS)
#
BLD_TYPE= calc-dynamic-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
LD_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use gcc's -Werror to force warnings
# to become errors, call make with:
#
#   make .. COMMON_ADD='-Werror'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
endif

#################
# Cygwin target #
#################

ifeq ($(target),Cygwin)
#
BLD_TYPE= calc-static-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
LD_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use gcc's -Werror to force warnings
# to become errors, call make with:
#
#   make .. COMMON_ADD='-Werror'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
endif

#######################################################
# simple target - values used to form Makefile.simple #
#######################################################

# NOTE: This is not a real host target.  The simple target
#	exists only to form the Makefile.simple file.

ifeq ($(target),simple)
#endif	/* end of skip for non-Gnu makefiles */
#
BLD_TYPE= calc-static-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
#
CC_STATIC=
LD_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= cc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
# The simple makefile forces the use of static ${CC} flags
#
# ICFLAGS are given to ${CC} for intermediate programs used to help compile calc
# CFLAGS are given to ${CC} for calc programs other than intermediate programs
# ILDFLAGS for ${CC} in linking intermediate programs used to help compile calc
# LDFLAGS for ${CC} in linking calc programs other than intermediate programs
#
ICFLAGS= ${COMMON_CFLAGS} ${CC_STATIC}
CFLAGS= ${ICFLAGS} ${CCOPT}
#
ILDFLAGS= ${COMMON_LDFLAGS} ${LD_STATIC}
LDFLAGS= ${LD_DEBUG} ${ILDFLAGS} ${LIBCALC_STATIC} ${LIBCUSTCALC_STATIC}
#
#if 0	/* start of skip for non-Gnu makefiles */
endif

###################################################
# MINGW32_NT-5.0 target                           #
###################################################


ifeq ($(target),MINGW32_NT-5.0)

EXT=.exe
TERMCONTROL= -DUSE_WIN32
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
CALCPATH= .;./cal;~/.cal;${T}${CALC_SHAREDIR};${T}${CUSTOMCALDIR}
#if 0	/* start of skip for non-Gnu makefiles */
else
CALCPATH= .;./cal;~/.cal;${T}${CALC_SHAREDIR}
endif
CALCRC= ${CALC_SHAREDIR}/startup;~/.calcrc;./.calcinit
#
BLD_TYPE= calc-static-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC= -DSTATIC_ONLY
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
LD_STATIC=
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC= -DNOTCYGWIN
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
endif

###################################################
# default target - when no specific target exists #
###################################################

# NOTE: This is the default generic host target.  Used when no other
#	host target matches.

ifeq ($(target),)
#
BLD_TYPE= calc-static-only
#
CC_SHARE= -fPIC
DEFAULT_LIB_INSTALL_PATH= ${PWD}:/lib:/usr/lib:${LIBDIR}:/usr/local/lib
LD_SHARE= "-Wl,-rpath,${DEFAULT_LIB_INSTALL_PATH}" \
    "-Wl,-rpath-link,${DEFAULT_LIB_INSTALL_PATH}"
LIBCALC_SHLIB= -shared "-Wl,-soname,libcalc${LIB_EXT_VERSION}"
ifdef ALLOW_CUSTOM
LIBCUSTCALC_SHLIB= -shared "-Wl,-soname,libcustcalc${LIB_EXT_VERSION}"
else
LIBCUSTCALC_SHLIB=
endif
#
CC_STATIC=
LIBCALC_STATIC=
LIBCUSTCALC_STATIC=
LD_STATIC=
#
# If you want to add flags to all compiler and linker
# run (via ${COMMON_CFLAGS} and ${COMMON_LDFLAGS}),
# set ${COMMON_ADD}.
#
# For example to use gcc's -Werror to force warnings
# to become errors, call make with:
#
#   make .. COMMON_ADD='-Werror'
#
# This facility requires a Gnu Makefile, or a make command
# that understands the += make operand.
#
#if 0	/* start of skip for non-Gnu makefiles */
COMMON_CFLAGS+= ${COMMON_ADD}
COMMON_LDFLAGS+= ${COMMON_ADD}
#endif	/* end of skip for non-Gnu makefiles */
#
CCWARN= -Wall
WNO_IMPLICT= -Wno-implicit
WNO_ERROR_LONG_LONG= -Wno-error=long-long
WNO_LONG_LONG= -Wno-long-long
CCWERR=
CCOPT= ${DEBUG}
CCMISC=
#
LCC= gcc
CC= ${PURIFY} ${LCC} ${CCWERR}
#
endif

###########################################
# Set the default compile flags for ${CC} #
###########################################

# Required flags to compile C files for calc
#
# ICFLAGS are given to ${CC} for intermediate programs used to help compile calc
# CFLAGS are given to ${CC} for calc programs other than intermediate programs
#
# NOTE: This does not work for: make-XYZ-only and BLD_TYPE != make-XYZ-only
#
ifeq ($(BLD_TYPE),calc-static-only)
ICFLAGS= ${COMMON_CFLAGS} ${CC_STATIC}
else
ICFLAGS= ${COMMON_CFLAGS} ${CC_SHARE}
endif
CFLAGS= ${ICFLAGS} ${CCOPT}

# Required flags to link files for calc
#
# ILDFLAGS for ${CC} in linking intermediate programs used to help compile calc
# LDFLAGS for ${CC} in linking calc programs other than intermediate programs
#
ILDFLAGS= ${COMMON_LDFLAGS}
LDFLAGS= ${LD_DEBUG} ${ILDFLAGS}
#endif	/* end of skip for non-Gnu makefiles */

#######################################################################
#-=-=-=-=-=- end of target section - only make rules below -=-=-=-=-=-#
#######################################################################
# end of host target cut - Do not remove this line

###############################################################################
#=-=-=-=-=- Be careful if you change something in this next section -=-=-=-=-=#
###############################################################################

# Makefile debug
#
# Q=@	do not echo internal Makefile actions (quiet mode)
# Q=	echo internal Makefile actions (debug / verbose mode)
#
# V=@:	do not echo debug statements (quiet mode)
# V=@	do echo debug statements (debug / verbose mode)
#
#Q=
Q=@
V=@:
#V=@

# the source files which are built into a math link library
#
# There MUST be a .o for every .c in LIBOBJS
#
LIBSRC= addop.c assocfunc.c blkcpy.c block.c byteswap.c \
	codegen.c comfunc.c commath.c config.c const.c custom.c \
	file.c func.c hash.c help.c hist.c input.c jump.c label.c \
	lib_calc.c lib_util.c listfunc.c matfunc.c math_error.c \
	obj.c opcodes.c pix.c poly.c prime.c qfunc.c qio.c \
	qmath.c qmod.c qtrans.c quickhash.c seed.c sha1.c size.c \
	str.c symbol.c token.c value.c version.c zfunc.c zio.c \
	zmath.c zmod.c zmul.c zprime.c zrand.c zrandom.c

# the object files which are built into a math link library
#
# There MUST be a .o for every .c in LIBSRC plus calcerr.o
# which is built via this Makefile.
#
LIBOBJS= addop.o assocfunc.o blkcpy.o block.o byteswap.o calcerr.o \
	codegen.o comfunc.o commath.o config.o const.o custom.o \
	file.o func.o hash.o help.o hist.o input.o jump.o label.o \
	lib_calc.o lib_util.o listfunc.o matfunc.o math_error.o \
	obj.o opcodes.o pix.o poly.o prime.o qfunc.o qio.o \
	qmath.o qmod.o qtrans.o quickhash.o seed.o sha1.o size.o \
	str.o symbol.o token.o value.o version.o zfunc.o zio.o \
	zmath.o zmod.o zmul.o zprime.o zrand.o zrandom.o

# the calculator source files
#
# There MUST be a .c for every .o in CALCOBJS.
#
CALCSRC= calc.c

# we build these .o files for calc
#
# There MUST be a .o for every .c in CALCSRC.
#
CALCOBJS= calc.o

# these .h files are needed to build the math link library
#
LIB_H_SRC= alloc.h blkcpy.h block.h byteswap.h calc.h cmath.h \
	config.h custom.h decl.h file.h func.h hash.h hist.h jump.h \
	label.h lib_util.h lib_calc.h nametype.h \
	opcodes.h prime.h qmath.h sha1.h str.h \
	symbol.h token.h value.h zmath.h zrand.h zrandom.h

# we build these .h files during the make
#
BUILD_H_SRC= align32.h args.h calcerr.h conf.h endian_calc.h \
	fposval.h have_const.h have_fpos.h have_fpos_pos.h \
	have_memmv.h have_newstr.h have_offscl.h have_posscl.h \
	have_stdlib.h have_string.h have_times.h have_uid_t.h \
	have_unistd.h longbits.h terminal.h \
	have_ustat.h have_getsid.h have_getpgid.h \
	have_gettime.h have_getprid.h have_urandom.h have_rusage.h \
	have_strdup.h have_unused.h

# we build these .c files during the make
#
BUILD_C_SRC= calcerr.c

# these .c files may be used in the process of building BUILD_H_SRC
#
# There MUST be a .c for every .o in UTIL_OBJS.
#
UTIL_C_SRC= align32.c endian.c longbits.c have_newstr.c have_uid_t.c \
	have_const.c have_stdvs.c have_varvs.c fposval.c have_fpos.c \
	have_fpos_pos.c have_offscl.c have_posscl.c have_memmv.c \
	have_ustat.c have_getsid.c have_getpgid.c \
	have_gettime.c have_getprid.c have_rusage.c have_strdup.c \
	have_unused.c

# these awk and sed tools are used in the process of building BUILD_H_SRC
# and BUILD_C_SRC
#
UTIL_MISC_SRC= calcerr_h.sed calcerr_h.awk calcerr_c.sed calcerr_c.awk \
	calcerr.tbl check.awk win32.mkdef

# these .o files may get built in the process of building BUILD_H_SRC
#
# There MUST be a .o for every .c in UTIL_C_SRC.
#
UTIL_OBJS= endian.o longbits.o have_newstr.o have_uid_t.o \
	have_const.o fposval.o have_fpos.o have_fpos_pos.o \
	try_strarg.o have_stdvs.o have_varvs.o have_posscl.o have_memmv.o \
	have_ustat.o have_getsid.o have_getpgid.o \
	have_gettime.o have_getprid.o ver_calc.o have_rusage.o have_strdup.o \
	have_unused.o

# these temp files may be created (and removed) during the build of BUILD_C_SRC
#
UTIL_TMP= ll_tmp fpos_tmp fposv_tmp const_tmp uid_tmp newstr_tmp vs_tmp \
	memmv_tmp offscl_tmp posscl_tmp newstr_tmp \
	getsid_tmp gettime_tmp getprid_tmp rusage_tmp strdup_tmp

# these utility executables may be created in the process of
# building the BUILD_H_SRC file set
#
UTIL_PROGS= align32${EXT} fposval${EXT} have_uid_t${EXT} have_const${EXT} \
	endian${EXT} longbits${EXT} have_newstr${EXT} have_stdvs${EXT} \
	have_varvs${EXT} have_ustat${EXT} have_getsid${EXT} \
	have_getpgid${EXT} have_gettime${EXT} have_getprid${EXT} \
	ver_calc${EXT} have_strdup${EXT} \
	have_unused${EXT} have_fpos${EXT} have_fpos_pos${EXT} \
	have_offscl${EXT} have_rusage${EXT}

# these utility files and scripts may be created in the process of building
# the BUILD_H_SRC file set
#
UTIL_FILES= have_args.sh

# Any .h files that are needed to compile sample code.
#
SAMPLE_H_SRC=

# Any .c files that are needed to compile sample code.
#
# There MUST be a .c in SAMPLE_C_SRC for every .o in SAMPLE_OBJ.
#
SAMPLE_C_SRC= sample_many.c sample_rand.c

# Any .o files that are needed to compile sample code.
#
# There MUST be a .c in SAMPLE_C_SRC for every .o in SAMPLE_OBJ.
#
SAMPLE_OBJ= sample_many.o sample_rand.o

# The complete list of Makefile vars passed down to custom/Makefile.
#
CUSTOM_PASSDOWN=  \
    ALLOW_CUSTOM="${ALLOW_CUSTOM}" \
    AR=${AR} \
    AWK=${AWK} \
    BINDIR="${BINDIR}" \
    BLD_TYPE="${BLD_TYPE}" \
    CALC_INCDIR="${CALC_INCDIR}" \
    CALC_SHAREDIR="${CALC_SHAREDIR}" \
    CAT=${CAT} \
    CC="${CC}" \
    CCERR="${CCERR}" \
    CCMISC="${CCMISC}" \
    CCOPT="${CCOPT}" \
    CCWARN="${CCWARN}" \
    CC_SHARE="${CC_SHARE}" \
    CFLAGS="${CFLAGS} -I.." \
    CHMOD=${CHMOD} \
    CMP=${CMP} \
    CO=${CO} \
    COMMON_ADD="${COMMON_ADD}" \
    COMMON_CFLAGS="${COMMON_CFLAGS} -I.." \
    COMMON_LDFLAGS="${COMMON_LDFLAGS}" \
    CP=${CP} \
    CUSTOMCALDIR="${CUSTOMCALDIR}" \
    CUSTOMHELPDIR="${CUSTOMHELPDIR}" \
    CUSTOMINCDIR="${CUSTOMINCDIR}" \
    DEBUG="${DEBUG}" \
    DEFAULT_LIB_INSTALL_PATH="${DEFAULT_LIB_INSTALL_PATH}" \
    FMT=${FMT} \
    GREP=${GREP} \
    HELPDIR="${HELPDIR}" \
    ICFLAGS="${ICFLAGS} -I.." \
    ILDFLAGS="${ILDFLAGS}" \
    INCDIR="${INCDIR}" \
    LANG=${LANG} \
    LCC="${LCC}" \
    LDCONFIG=${LDCONFIG} \
    LDFLAGS="${LDFLAGS}" \
    LD_SHARE="${LD_SHARE}" \
    LIBCUSTCALC_SHLIB="${LIBCUSTCALC_SHLIB}" \
    LIBDIR="${LIBDIR}" \
    LN=${LN} \
    MAKE=${MAKE} \
    MAKEDEPEND=${MAKEDEPEND} \
    MAKE_FILE=Makefile \
    MKDIR=${MKDIR} \
    MV=${MV} \
    PURIFY="${PURIFY}" \
    Q="${Q}" \
    RANLIB="${RANLIB}" \
    RM=${RM} \
    RMDIR=${RMDIR} \
    SCRIPTDIR="${SCRIPTDIR}" \
    SED=${SED} \
    SORT=${SORT} \
    T=${T} \
    TOP_MAKE_FILE=${MAKE_FILE} \
    TOUCH=${TOUCH} \
    TRUE=${TRUE} \
    VERSION=${VERSION} \
    target=${target}

# The complete list of Makefile vars passed down to help/Makefile.
#
HELP_PASSDOWN= \
    AR=${AR} \
    BINDIR="${BINDIR}" \
    CALC_INCDIR="${CALC_INCDIR}" \
    CALC_SHAREDIR="${CALC_SHAREDIR}" \
    CAT=${CAT} \
    CFLAGS="${CFLAGS}" \
    CHMOD=${CHMOD} \
    CMP=${CMP} \
    CO=${CO} \
    COMMON_ADD="${COMMON_ADD}" \
    COMMON_CFLAGS="${COMMON_CFLAGS}" \
    COMMON_LDFLAGS="${COMMON_LDFLAGS}" \
    CP=${CP} \
    EXT=${EXT} \
    FMT=${FMT} \
    GREP=${GREP} \
    HELPDIR="${HELPDIR}" \
    ICFLAGS="${ICFLAGS}" \
    ILDFLAGS="${ILDFLAGS}" \
    INCDIR="${INCDIR}" \
    LANG=${LANG} \
    LCC="${LCC}" \
    LIBDIR="${LIBDIR}" \
    MAKE_FILE=Makefile \
    MKDIR=${MKDIR} \
    MV=${MV} \
    Q="${Q}" \
    RM=${RM} \
    RMDIR=${RMDIR} \
    SCRIPTDIR="${SCRIPTDIR}" \
    SED=${SED} \
    T=${T} \
    TOP_MAKE_FILE=${MAKE_FILE} \
    TOUCH=${TOUCH} \
    TRUE=${TRUE}

# The complete list of Makefile vars passed down to cal/Makefile.
#
CAL_PASSDOWN= \
    AR=${AR} \
    BINDIR="${BINDIR}" \
    CALC_INCDIR="${CALC_INCDIR}" \
    CALC_SHAREDIR="${CALC_SHAREDIR}" \
    CAT=${CAT} \
    CHMOD=${CHMOD} \
    CMP=${CMP} \
    CO=${CO} \
    CP=${CP} \
    HELPDIR="${HELPDIR}" \
    INCDIR="${INCDIR}" \
    LANG=${LANG} \
    LIBDIR="${LIBDIR}" \
    MAKE_FILE=Makefile \
    MKDIR=${MKDIR} \
    MV=${MV} \
    Q="${Q}" \
    RM=${RM} \
    RMDIR=${RMDIR} \
    SCRIPTDIR="${SCRIPTDIR}" \
    T=${T} \
    TOP_MAKE_FILE=${MAKE_FILE} \
    TOUCH=${TOUCH} \
    TRUE=${TRUE}

# The complete list of Makefile vars passed down to cscript/Makefile.
#
CSCRIPT_PASSDOWN= \
    AR=${AR} \
    BINDIR="${BINDIR}" \
    CALC_INCDIR="${CALC_INCDIR}" \
    CALC_SHAREDIR="${CALC_SHAREDIR}" \
    CAT=${CAT} \
    CHMOD=${CHMOD} \
    CMP=${CMP} \
    CO=${CO} \
    CP=${CP} \
    FMT=${FMT} \
    HELPDIR="${HELPDIR}" \
    INCDIR="${INCDIR}" \
    LANG=${LANG} \
    LIBDIR="${LIBDIR}" \
    MAKE_FILE=Makefile \
    MKDIR=${MKDIR} \
    MV=${MV} \
    Q="${Q}" \
    RM=${RM} \
    RMDIR=${RMDIR} \
    SCRIPTDIR="${SCRIPTDIR}" \
    SED=${SED} \
    SORT=${SORT} \
    T=${T} \
    TOP_MAKE_FILE=${MAKE_FILE} \
    TOUCH=${TOUCH} \
    TRUE=${TRUE}

# complete list of .h files found (but not built) in the distribution
#
H_SRC= ${LIB_H_SRC} ${SAMPLE_H_SRC}

# complete list of .c files found (but not built) in the distribution
#
C_SRC= ${LIBSRC} ${CALCSRC} ${UTIL_C_SRC} ${SAMPLE_C_SRC}

# The list of files that describe calc's GNU Lesser General Public License
#
LICENSE= COPYING COPYING-LGPL

# These files are found (but not built) in the distribution
#
DISTLIST= ${C_SRC} ${H_SRC} ${MAKE_FILE} BUGS CHANGES LIBRARY README.FIRST \
	  README.WINDOWS calc.man HOWTO.INSTALL ${UTIL_MISC_SRC} ${LICENSE} \
	  sample.README calc.spec.in rpm.mk README.md

# These files are used to make (but not build) a calc .a link library
#
CALCLIBLIST= ${LIBSRC} ${UTIL_C_SRC} ${LIB_H_SRC} ${MAKE_FILE} \
	     ${UTIL_MISC_SRC} BUGS CHANGES LIBRARY

# complete list of .o files
#
OBJS= ${LIBOBJS} ${CALCOBJS} ${UTIL_OBJS} ${SAMPLE_OBJ}

# static library build
#
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
CALC_STATIC_LIBS= libcalc.a libcustcalc.a
#if 0	/* start of skip for non-Gnu makefiles */
else
CALC_STATIC_LIBS= libcalc.a
endif
#endif	/* end of skip for non-Gnu makefiles */

# Libraries created and used to build calc
#
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
CALC_DYNAMIC_LIBS= libcalc${LIB_EXT_VERSION} libcustcalc${LIB_EXT_VERSION}
#if 0	/* start of skip for non-Gnu makefiles */
else
CALC_DYNAMIC_LIBS= libcalc${LIB_EXT_VERSION}
endif
#endif	/* end of skip for non-Gnu makefiles */

# Symlinks of dynamic shared libraries
#
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
SYM_DYNAMIC_LIBS= libcalc${LIB_EXT} \
	libcustcalc${LIB_EXT_VERSION}  libcustcalc${LIB_EXT}
#if 0	/* start of skip for non-Gnu makefiles */
else
SYM_DYNAMIC_LIBS= libcalc${LIB_EXT}
endif
#endif	/* end of skip for non-Gnu makefiles */

# list of sample programs that need to be built to satisfy sample rule
#
# NOTE: The ${SAMPLE_TARGETS} and ${SAMPLE_STATIC_TARGETS} are built but
#	not installed at this time.
#
# NOTE: There must be a foo-static${EXT} in SAMPLE_STATIC_TARGETS for
#	every foo${EXT} in ${SAMPLE_TARGETS}.
#
SAMPLE_TARGETS= sample_rand${EXT} sample_many${EXT}
SAMPLE_STATIC_TARGETS= sample_rand-static${EXT} sample_many-static${EXT}

# list of cscript programs that need to be built to satisfy cscript/.all
#
# NOTE: This list MUST be coordinated with the ${CSCRIPT_TARGETS} variable
#	in the cscript/Makefile
#
CSCRIPT_TARGETS= cscript/mersenne cscript/piforever cscript/plus \
		 cscript/square cscript/fproduct cscript/powerterm

# dynamic first targets
#
DYNAMIC_FIRST_TARGETS= ${LICENSE} .dynamic

# static first targets
#
STATIC_FIRST_TARGETS= ${LICENSE} .static

# early targets - things needed before the main build phase can begin
#
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
EARLY_TARGETS= custom/Makefile hsrc .hsrc custom/.all
#if 0	/* start of skip for non-Gnu makefiles */
else
EARLY_TARGETS= hsrc .hsrc
endif
#endif	/* end of skip for non-Gnu makefiles */

# late targets - things needed after the main build phase is complete
#
LATE_TARGETS= calc.1 calc.usage \
	      cal/.all help/.all help/builtin cscript/.all \
	      Makefile.simple

# complete list of targets
#
TARGETS= ${EARLY_TARGETS} ${BLD_TYPE} ${LATE_TARGETS}

###
#
# The reason for this Makefile	:-)
#
###

all: check_include ${BLD_TYPE} CHANGES

check_include:
	$(Q) if [ ! -d /usr/include ]; then \
	    echo "ERROR: critical directory missing: /usr/include" 1>&2; \
	    echo "Without this critical directory, we cannot compile." 1>&2; \
	    echo 1>&2; \
	    echo "Perhaps your system isn't setup to compile C source?" 1>&2; \
	    echo "For example, Apple OS X / darwin requres that XCode" 1>&2; \
	    echo "must be installed and that you run the command:" 1>&2; \
	    echo 1>&2; \
	    echo "    xcode-select --install" 1>&2; \
	    echo 1>&2; \
	    exit 1; \
	fi
	$(Q) if [ ! -f /usr/include/stdio.h ]; then \
	    echo "ERROR: critical include files are missing" 1>&2; \
	    echo "Without this critical directory, we cannot compile." 1>&2; \
	    echo 1>&2; \
	    echo "Perhaps your system isn't setup to compile C source?" 1>&2; \
	    echo "For example, Apple OS X / darwin requres that XCode" 1>&2; \
	    echo "must be installed and that you run the command:" 1>&2; \
	    echo 1>&2; \
	    echo "    xcode-select --install" 1>&2; \
	    echo 1>&2; \
	    exit 1; \
	fi

prep:
	${Q} ${MAKE} -f ${MAKE_FILE} all DEBUG='-g3'

calc-dynamic-only: ${DYNAMIC_FIRST_TARGETS} ${EARLY_TARGETS} \
		   ${CALC_DYNAMIC_LIBS} ${SYM_DYNAMIC_LIBS} calc${EXT} \
		   ${SAMPLE_TARGETS} ${LATE_TARGETS}

.dynamic: ${MAKE_FILE}
	${Q} r="calc-dynamic-only"; \
	    if [ "${BLD_TYPE}" != "$$r" ]; then \
	    echo "NOTE: The host target $(target) defaults to a build" 1>&2; \
	    echo "      type of: ${BLD_TYPE}, so you need to use" 1>&2; \
	    echo "      the following make command:" 1>&2; \
	    echo "" 1>&2; \
	    echo "      ${MAKE} -f ${MAKE_FILE} clobber" 1>&2; \
	    echo "      ${MAKE} -f ${MAKE_FILE} $$r BLD_TYPE=$$r" 1>&2; \
	    echo "" 1>&2; \
	    echo "NOTE: It is a very good idea to first clobber any" 1>&2; \
	    echo "      previously built .o, libs and executables" 1>&2; \
	    echo "      before switching to $$r!" 1>&2; \
	    echo "" 1>&2; \
	    echo "=== aborting make ===" 1>&2; \
	    exit 1; \
	fi
	${Q} for i in .static calc-static${EXT} ${SAMPLE_STATIC_TARGETS} \
		      libcalc.a custom/libcustcalc.a; do \
	    r="calc-dynamic-only"; \
	    if [ -r "$$i" ]; then \
		echo "Found the static target $$i file.  You must:" 1>&2; \
		echo "" 1>&2; \
		echo "      ${MAKE} -f ${MAKE_FILE} clobber" 1>&2; \
		echo "      ${MAKE} -f ${MAKE_FILE} $$r BLD_TYPE=$$r" 1>&2; \
		echo "" 1>&2; \
		echo "to clean out any previously built static files." 1>&2; \
		echo "" 1>&2; \
		echo "=== aborting make ===" 1>&2; \
		exit 2; \
	    fi; \
	done
	 -${Q} ${TOUCH} $@

calc-static-only: ${STATIC_FIRST_TARGETS} ${EARLY_TARGETS} \
		  ${CALC_STATIC_LIBS} calc-static${EXT} \
		  ${SAMPLE_STATIC_TARGETS} ${LATE_TARGETS}
	${Q} for i in calc${EXT} ${SAMPLE_TARGETS}; do \
	    if ${CMP} -s "$$i-static" "$$i"; then \
		${TRUE}; \
	    else \
		${RM} -f "$$i"; \
		${LN} "$$i-static" "$$i"; \
	    fi; \
	done

.static: ${MAKE_FILE}
	${Q} r="calc-static-only"; \
	    if [ "${BLD_TYPE}" != "$$r" ]; then \
	    echo "NOTE: The host target $(target) defaults to a build" 1>&2; \
	    echo "      type of: ${BLD_TYPE}, so you need to use" 1>&2; \
	    echo "      the following make command:" 1>&2; \
	    echo "" 1>&2; \
	    echo "      ${MAKE} -f ${MAKE_FILE} clobber" 1>&2; \
	    echo "      ${MAKE} -f ${MAKE_FILE} $$r BLD_TYPE=$$r" 1>&2; \
	    echo "" 1>&2; \
	    echo "NOTE: It is a very good idea to first clobber any" 1>&2; \
	    echo "      previously built .o, libs and executables" 1>&2; \
	    echo "      before switching to $$r!" 1>&2; \
	    echo "" 1>&2; \
	    echo "=== aborting make ===" 1>&2; \
	    exit 3; \
	fi
	${Q} for i in .dynamic ${CALC_DYNAMIC_LIBS} ${SYM_DYNAMIC_LIBS} \
		      custom/libcustcalc${LIB_EXT_VERSION}; do \
	    r="calc-static-only"; \
	    if [ -r "$$i" ]; then \
		echo "Found the dynamic target $$i file.  You must:" 1>&2; \
		echo "" 1>&2; \
		echo "      ${MAKE} -f ${MAKE_FILE} clobber" 1>&2; \
		echo "      ${MAKE} -f ${MAKE_FILE} $$r BLD_TYPE=$$r" 1>&2; \
		echo "" 1>&2; \
		echo "to clean out any previously built dynamic files." 1>&2; \
		echo "" 1>&2; \
		echo "=== aborting make ===" 1>&2; \
		exit 4; \
	    fi; \
	done
	 -${Q} ${TOUCH} $@

calc${EXT}: .hsrc ${CALCOBJS} ${CALC_DYNAMIC_LIBS} ${MAKE_FILE}
	${RM} -f $@
	${CC} ${CALCOBJS} ${LDFLAGS} ${LD_SHARE} ${CALC_DYNAMIC_LIBS} \
	      ${READLINE_LIB} ${READLINE_EXTRAS} -o $@

libcalc${LIB_EXT_VERSION}: ${LIBOBJS} ver_calc${EXT} ${MAKE_FILE}
	${CC} ${LIBCALC_SHLIB} ${LIBOBJS} \
	      ${READLINE_LIB} ${READLINE_EXTRAS} -o libcalc${LIB_EXT_VERSION}

libcalc${LIB_EXT}: libcalc${LIB_EXT_VERSION}
	${Q} ${RM} -f $@
	${LN} -s $? $@

###
#
# calc documentation
#
###

calc.1: calc.man ${MAKE_FILE}
	${RM} -f $@
	${Q} echo forming calc.1 from calc.man
	@${SED} -e 's:$${LIBDIR}:${LIBDIR}:g' \
	        -e 's,$${BINDIR},${BINDIR},g' \
	        -e 's,$${VERSION},${VERSION},g' \
	        -e 's,$${CALCPATH},${CALCPATH},g' \
	        -e 's,$${SCRIPTDIR},${SCRIPTDIR},g' \
	        -e 's,$${CALC_INCDIR},${CALC_INCDIR},g' \
	        -e 's,$${CUSTOMCALDIR},${CUSTOMCALDIR},g' \
	        -e 's,$${CUSTOMINCDIR},${CUSTOMINCDIR},g' \
	        -e 's,$${CUSTOMHELPDIR},${CUSTOMHELPDIR},g' \
	        -e 's,$${CALCRC},${CALCRC},g' < calc.man > calc.1
	${Q} echo calc.1 formed

calc.usage: calc.1 ${MAKE_FILE}
	${RM} -f $@
	${Q} echo forming calc.usage from calc.1
	${Q} if [ -z "${NROFF}" ]; then \
	    LESSCHARSET=iso8859 ${CALCPAGER} calc.1; \
	else \
	    ${NROFF} -man calc.1; \
	fi | ${COL} -b > $@
	${Q} echo calc.usage formed


##
#
# These rules compile the sample code against the calc library
#
##

sample: ${SAMPLE_TARGETS}

sample_rand${EXT}: sample_rand.o ${CALC_DYNAMIC_LIBS} ${MAKE_FILE}
	${CC} sample_rand.o ${LDFLAGS} ${LD_SHARE} ${CALC_DYNAMIC_LIBS} \
	      ${READLINE_LIB} ${READLINE_EXTRAS} -o $@

sample_many${EXT}: sample_many.o ${CALC_DYNAMIC_LIBS} ${MAKE_FILE}
	${CC} sample_many.o ${LDFLAGS} ${LD_SHARE} ${CALC_DYNAMIC_LIBS} \
	      ${READLINE_LIB} ${READLINE_EXTRAS} -o $@

###
#
# Special .o files that may need special compile options
#
###

hist.o: hist.c ${MAKE_FILE}
	${CC} ${CFLAGS} ${TERMCONTROL} ${USE_READLINE} ${READLINE_INCLUDE} \
	    -c hist.c

seed.o: seed.c ${MAKE_FILE}
	${CC} ${CFLAGS} ${WNO_IMPLICT} ${WNO_ERROR_LONG_LONG} \
	    ${WNO_LONG_LONG} -c seed.c

file.o: file.c ${MAKE_FILE}
	${CC} ${CFLAGS} ${WNO_ERROR_LONG_LONG} ${WNO_LONG_LONG} -c file.c

###
#
# The next set of rules cause the .h files BUILD_H_SRC files to be built
# according to the system and the Makefile variables above.  The hsrc rule
# is a convenient rule to invoke to build all of the BUILD_H_SRC.
#
# We add in the BUILD_C_SRC files because they are similar to the
# BUILD_H_SRC files in terms of the build process.
#
# NOTE: Due to bogus shells found on one common system we must have
#	an non-empty else clause for every if condition.  *sigh*
#	We also place ; ${TRUE} at the end of some commands to avoid
#	meaningless cosmetic messages by the same system.
#
###

hsrc: ${BUILD_H_SRC} ${BUILD_C_SRC}

.hsrc: ${BUILD_H_SRC} ${BUILD_C_SRC}
	${Q} ${RM} -f .hsrc
	-${Q} ${TOUCH} .hsrc

conf.h: ${MAKE_FILE}
	${Q} ${RM} -f conf.h
	${Q} echo 'forming conf.h'
	${Q} echo '/*' > conf.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> conf.h
	${Q} echo ' */' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '#if !defined(__CONF_H__)' >> conf.h
	${Q} echo '#define __CONF_H__' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '/* the default :-separated search path */' >> conf.h
	${Q} echo '#if !defined(DEFAULTCALCPATH)' >> conf.h
	${Q} echo '#define DEFAULTCALCPATH "${CALCPATH}"' >> conf.h
	${Q} echo '#endif /* DEFAULTCALCPATH */' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '/* the default :-separated startup file list */' >> conf.h
	${Q} echo '#if !defined(DEFAULTCALCRC)' >> conf.h
	${Q} echo '#define DEFAULTCALCRC "${CALCRC}"' >> conf.h
	${Q} echo '#endif /* DEFAULTCALCRC */' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '/* the location of the help directory */' >> conf.h
	${Q} echo '#if !defined(HELPDIR)' >> conf.h
#if 0	/* start of skip for non-Gnu makefiles */
ifdef RPM_TOP
	${Q} echo '#define HELPDIR "${HELPDIR}"' >> conf.h
else
#endif	/* end of skip for non-Gnu makefiles */
	${Q} echo '#define HELPDIR "${T}${HELPDIR}"' >> conf.h
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */
	${Q} echo '#endif /* HELPDIR */' >> conf.h
	${Q} echo '' >> conf.h
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
	${Q} echo '/* the location of the custom help directory */' >> conf.h
	${Q} echo '#if !defined(CUSTOMHELPDIR)' >> conf.h
#if 0	/* start of skip for non-Gnu makefiles */
ifdef RPM_TOP
	${Q} echo '#define CUSTOMHELPDIR "${CUSTOMHELPDIR}"' >> conf.h
else
#endif	/* end of skip for non-Gnu makefiles */
	${Q} echo '#define CUSTOMHELPDIR "${T}${CUSTOMHELPDIR}"' >> conf.h
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */
	${Q} echo '#endif /* CUSTOMHELPDIR */' >> conf.h
	${Q} echo '' >> conf.h
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */
	${Q} echo '/* the default pager to use */' >> conf.h
	${Q} echo '#if !defined(DEFAULTCALCPAGER)' >> conf.h
	${Q} echo '#define DEFAULTCALCPAGER "${CALCPAGER}"' >> conf.h
	${Q} echo '#endif /* DEFAULTCALCPAGER */' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '' >> conf.h
	${Q} echo '#endif /* !__CONF_H__ */' >> conf.h
	${Q} echo 'conf.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

endian_calc.h: endian${EXT} ${MAKE_FILE}
	${Q} ${RM} -f endian_calc.h
	${Q} echo 'forming endian_calc.h'
	${Q} echo '/*' > endian_calc.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> endian_calc.h
	${Q} echo ' */' >> endian_calc.h
	${Q} echo '' >> endian_calc.h
	${Q} echo '' >> endian_calc.h
	${Q} echo '#if !defined(__ENDIAN_CALC_H__)' >> endian_calc.h
	${Q} echo '#define __ENDIAN_CALC_H__' >> endian_calc.h
	${Q} echo '' >> endian_calc.h
	${Q} echo '' >> endian_calc.h
	${Q} echo '/* what byte order are we? */' >> endian_calc.h
	-${Q} if [ X"${CALC_BYTE_ORDER}" = X ]; then \
	    if [ -f ${INCDIR}/endian.h ]; then \
		echo '#include <endian.h>' >> endian_calc.h; \
		echo '#define CALC_BYTE_ORDER BYTE_ORDER' >> endian_calc.h; \
	    elif [ -f ${INCDIR}/machine/endian.h ]; then \
		echo '#include <machine/endian.h>' >> endian_calc.h; \
		echo '#define CALC_BYTE_ORDER BYTE_ORDER' >> endian_calc.h; \
	    elif [ -f ${INCDIR}/sys/endian.h ]; then \
		echo '#include <sys/endian.h>' >> endian_calc.h; \
		echo '#define CALC_BYTE_ORDER BYTE_ORDER' >> endian_calc.h; \
	    elif [ -f /usr/include/endian.h ]; then \
		echo '#include <endian.h>' >> endian_calc.h; \
		echo '#define CALC_BYTE_ORDER BYTE_ORDER' >> endian_calc.h; \
	    elif [ -f /usr/include/machine/endian.h ]; then \
		echo '#include <machine/endian.h>' >> endian_calc.h; \
		echo '#define CALC_BYTE_ORDER BYTE_ORDER' >> endian_calc.h; \
	    elif [ -f /usr/include/sys/endian.h ]; then \
		echo '#include <sys/endian.h>' >> endian_calc.h; \
		echo '#define CALC_BYTE_ORDER BYTE_ORDER' >> endian_calc.h; \
	    else \
		./endian${EXT} >> endian_calc.h; \
	    fi; \
	else \
	    ./endian${EXT} >> endian_calc.h; \
	fi
	${Q} echo '' >> endian_calc.h
	${Q} echo '' >> endian_calc.h
	${Q} echo '#endif /* !__ENDIAN_CALC_H__ */' >> endian_calc.h
	${Q} echo 'endian_calc.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

longbits.h: longbits${EXT} ${MAKE_FILE}
	${Q} ${RM} -f longbits.h
	${Q} echo 'forming longbits.h'
	${Q} echo '/*' > longbits.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> longbits.h
	${Q} echo ' */' >> longbits.h
	${Q} echo '' >> longbits.h
	${Q} echo '' >> longbits.h
	${Q} echo '#if !defined(__LONGBITS_H__)' >> longbits.h
	${Q} echo '#define __LONGBITS_H__' >> longbits.h
	${Q} echo '' >> longbits.h
	${Q} echo '' >> longbits.h
	${Q} ./longbits${EXT} ${LONG_BITS} >> longbits.h
	${Q} echo '' >> longbits.h
	${Q} echo '' >> longbits.h
	${Q} echo '#endif /* !__LONGBITS_H__ */' >> longbits.h
	${Q} echo 'longbits.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_times.h: ${MAKE_FILE}
	${Q} ${RM} -f have_times.h
	${Q} echo 'forming have_times.h'
	${Q} echo '/*' > have_times.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_times.h
	${Q} echo ' */' >> have_times.h
	${Q} echo '' >> have_times.h
	${Q} echo '' >> have_times.h
	${Q} echo '#if !defined(CALC_HAVE_TIMES_H)' >> have_times.h
	${Q} echo '#define CALC_HAVE_TIMES_H' >> have_times.h
	${Q} echo '' >> have_times.h
	${Q} echo '' >> have_times.h
	${Q} echo '/* do we have <times.h>? */' >> have_times.h
	-${Q} if [ X"${HAVE_TIMES_H}" = X"YES" ]; then \
	    echo '#define HAVE_TIMES_H	/* yes */' >> have_times.h; \
	elif [ X"${HAVE_TIMES_H}" = X"NO" ]; then \
	    echo '#undef HAVE_TIMES_H  /* no */' >> have_times.h; \
	elif [ -f ${INCDIR}/times.h ]; then \
	    echo '#define HAVE_TIMES_H	/* yes */' >> have_times.h; \
	elif [ -f /usr/include/times.h ]; then \
	    echo '#define HAVE_TIMES_H	/* yes */' >> have_times.h; \
	else \
	    echo '#undef HAVE_TIMES_H  /* no */' >> have_times.h; \
	fi
	-${Q} if [ X"${HAVE_SYS_TIMES_H}" = X"YES" ]; then \
	    echo '#define HAVE_SYS_TIMES_H	/* yes */' >> have_times.h; \
	elif [ X"${HAVE_SYS_TIMES_H}" = X"NO" ]; then \
	    echo '#undef HAVE_SYS_TIMES_H  /* no */' >> have_times.h; \
	elif [ -f ${INCDIR}/sys/times.h ]; then \
	    echo '#define HAVE_SYS_TIMES_H  /* yes */' >> have_times.h; \
	elif [ -f /usr/include/sys/times.h ]; then \
	    echo '#define HAVE_SYS_TIMES_H  /* yes */' >> have_times.h; \
	else \
	    echo '#undef HAVE_SYS_TIMES_H  /* no */' >> have_times.h; \
	fi
	-${Q} if [ X"${HAVE_TIME_H}" = X"YES" ]; then \
	    echo '#define HAVE_TIME_H	/* yes */' >> have_times.h; \
	elif [ X"${HAVE_TIME_H}" = X"NO" ]; then \
	    echo '#undef HAVE_TIME_H  /* no */' >> have_times.h; \
	elif [ -f ${INCDIR}/time.h ]; then \
	    echo '#define HAVE_TIME_H  /* yes */' >> have_times.h; \
	elif [ -f /usr/include/time.h ]; then \
	    echo '#define HAVE_TIME_H  /* yes */' >> have_times.h; \
	else \
	    echo '#undef HAVE_TIME_H  /* no */' >> have_times.h; \
	fi
	-${Q} if [ X"${HAVE_SYS_TIME_H}" = X"YES" ]; then \
	    echo '#define HAVE_SYS_TIME_H	/* yes */' >> have_times.h; \
	elif [ X"${HAVE_SYS_TIME_H}" = X"NO" ]; then \
	    echo '#undef HAVE_SYS_TIME_H  /* no */' >> have_times.h; \
	elif [ -f ${INCDIR}/sys/time.h ]; then \
	    echo '#define HAVE_SYS_TIME_H  /* yes */' >> have_times.h; \
	elif [ -f /usr/include/sys/time.h ]; then \
	    echo '#define HAVE_SYS_TIME_H  /* yes */' >> have_times.h; \
	else \
	    echo '#undef HAVE_SYS_TIME_H  /* no */' >> have_times.h; \
	fi
	${Q} echo '' >> have_times.h
	${Q} echo '' >> have_times.h
	${Q} echo '#endif /* !CALC_HAVE_TIMES_H */' >> have_times.h
	${Q} echo 'have_times.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_stdlib.h: ${MAKE_FILE}
	${Q} ${RM} -f have_stdlib.h
	${Q} echo 'forming have_stdlib.h'
	${Q} echo '/*' > have_stdlib.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_stdlib.h
	${Q} echo ' */' >> have_stdlib.h
	${Q} echo '' >> have_stdlib.h
	${Q} echo '' >> have_stdlib.h
	${Q} echo '#if !defined(CALC_HAVE_STDLIB_H)' >> have_stdlib.h
	${Q} echo '#define CALC_HAVE_STDLIB_H' >> have_stdlib.h
	${Q} echo '' >> have_stdlib.h
	${Q} echo '' >> have_stdlib.h
	${Q} echo '/* do we have <stdlib.h>? */' >> have_stdlib.h
	-${Q} if [ X"${HAVE_STDLIB_H}" = X"YES" ]; then \
	    echo '#define HAVE_STDLIB_H	/* yes */' >> have_stdlib.h; \
	elif [ X"${HAVE_STDLIB_H}" = X"NO" ]; then \
	    echo '#undef HAVE_STDLIB_H  /* no */' >> have_stdlib.h; \
	elif [ -f ${INCDIR}/stdlib.h ]; then \
	    echo '#define HAVE_STDLIB_H	 /* yes */' >> have_stdlib.h; \
	elif [ -f /usr/include/stdlib.h ]; then \
	    echo '#define HAVE_STDLIB_H	 /* yes */' >> have_stdlib.h; \
	else \
	    echo '#undef HAVE_STDLIB_H	/* no */' >> have_stdlib.h; \
	fi
	${Q} echo '' >> have_stdlib.h
	${Q} echo '' >> have_stdlib.h
	${Q} echo '#endif /* !CALC_HAVE_STDLIB_H */' >> have_stdlib.h
	${Q} echo 'have_stdlib.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_unistd.h: ${MAKE_FILE}
	${Q} ${RM} -f have_unistd.h
	${Q} echo 'forming have_unistd.h'
	${Q} echo '/*' > have_unistd.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_unistd.h
	${Q} echo ' */' >> have_unistd.h
	${Q} echo '' >> have_unistd.h
	${Q} echo '' >> have_unistd.h
	${Q} echo '#if !defined(CALC_HAVE_UNISTD_H)' >> have_unistd.h
	${Q} echo '#define CALC_HAVE_UNISTD_H' >> have_unistd.h
	${Q} echo '' >> have_unistd.h
	${Q} echo '' >> have_unistd.h
	${Q} echo '/* do we have <unistd.h>? */' >> have_unistd.h
	-${Q} if [ X"${HAVE_UNISTD_H}" = X"YES" ]; then \
	    echo '#define HAVE_UNISTD_H	/* yes */' >> have_unistd.h; \
	elif [ X"${HAVE_UNISTD_H}" = X"NO" ]; then \
	    echo '#undef HAVE_UNISTD_H  /* no */' >> have_unistd.h; \
	elif [ -f ${INCDIR}/unistd.h ]; then \
	    echo '#define HAVE_UNISTD_H	 /* yes */' >> have_unistd.h; \
	elif [ -f /usr/include/unistd.h ]; then \
	    echo '#define HAVE_UNISTD_H	 /* yes */' >> have_unistd.h; \
	else \
	    echo '#undef HAVE_UNISTD_H	/* no */' >> have_unistd.h; \
	fi
	${Q} echo '' >> have_unistd.h
	${Q} echo '' >> have_unistd.h
	${Q} echo '#endif /* !CALC_HAVE_UNISTD_H */' >> have_unistd.h
	${Q} echo 'have_unistd.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_string.h: ${MAKE_FILE}
	${Q} ${RM} -f have_string.h
	${Q} echo 'forming have_string.h'
	${Q} echo '/*' > have_string.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_string.h
	${Q} echo ' */' >> have_string.h
	${Q} echo '' >> have_string.h
	${Q} echo '' >> have_string.h
	${Q} echo '#if !defined(CALC_HAVE_STRING_H)' >> have_string.h
	${Q} echo '#define CALC_HAVE_STRING_H' >> have_string.h
	${Q} echo '' >> have_string.h
	${Q} echo '' >> have_string.h
	${Q} echo '/* do we have <string.h>? */' >> have_string.h
	-${Q} if [ X"${HAVE_STRING_H}" = X"YES" ]; then \
	    echo '#define HAVE_STRING_H	/* yes */' >> have_string.h; \
	elif [ X"${HAVE_STRING_H}" = X"NO" ]; then \
	    echo '#undef HAVE_STRING_H  /* no */' >> have_string.h; \
	elif [ -f ${INCDIR}/string.h ]; then \
	    echo '#define HAVE_STRING_H	 /* yes */' >> have_string.h; \
	elif [ -f /usr/include/string.h ]; then \
	    echo '#define HAVE_STRING_H	 /* yes */' >> have_string.h; \
	else \
	    echo '#undef HAVE_STRING_H	/* no */' >> have_string.h; \
	fi
	${Q} echo '' >> have_string.h
	${Q} echo '' >> have_string.h
	${Q} echo '#endif /* !CALC_HAVE_STRING_H */' >> have_string.h
	${Q} echo 'have_string.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

terminal.h: ${MAKE_FILE}
	${Q} ${RM} -f terminal.h
	${Q} echo 'forming terminal.h'
	${Q} echo '/*' > terminal.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> terminal.h
	${Q} echo ' */' >> terminal.h
	${Q} echo '' >> terminal.h
	${Q} echo '' >> terminal.h
	${Q} echo '#if !defined(__TERMINAL_H__)' >> terminal.h
	${Q} echo '#define __TERMINAL_H__' >> terminal.h
	${Q} echo '' >> terminal.h
	${Q} echo '' >> terminal.h
	${Q} echo '/* determine the type of terminal interface */' >> terminal.h
	${Q} echo '#if !defined(USE_TERMIOS)' >> terminal.h
	${Q} echo '#if !defined(USE_TERMIO)' >> terminal.h
	${Q} echo '#if !defined(USE_SGTTY)' >> terminal.h
	-${Q} if [ X"${TERMCONTROL}" = X"-DUSE_WIN32" ]; then \
	    echo '/* windoz, use none of these modes */' >> terminal.h; \
	    echo '#undef USE_TERMIOS   /* <termios.h> */' >> terminal.h; \
	    echo '#undef USE_TERMIO    /* <termio.h> */' >> terminal.h; \
	    echo '#undef USE_SGTTY     /* <sys/ioctl.h> */' >> terminal.h; \
	elif [ -f ${INCDIR}/termios.h ]; then \
	    echo '/* use termios */' >> terminal.h; \
	    echo '#define USE_TERMIOS  /* <termios.h> */' >> terminal.h; \
	    echo '#undef USE_TERMIO    /* <termio.h> */' >> terminal.h; \
	    echo '#undef USE_SGTTY     /* <sys/ioctl.h> */' >> terminal.h; \
	elif [ -f ${INCDIR}/termio.h ]; then \
	    echo '/* use termio */' >> terminal.h; \
	    echo '#undef USE_TERMIOS   /* <termios.h> */' >> terminal.h; \
	    echo '#define USE_TERMIO   /* <termio.h> */' >> terminal.h; \
	    echo '#undef USE_SGTTY     /* <sys/ioctl.h> */' >> terminal.h; \
	elif [ -f /usr/include/termios.h ]; then \
	    echo '/* use termios */' >> terminal.h; \
	    echo '#define USE_TERMIOS  /* <termios.h> */' >> terminal.h; \
	    echo '#undef USE_TERMIO    /* <termio.h> */' >> terminal.h; \
	    echo '#undef USE_SGTTY     /* <sys/ioctl.h> */' >> terminal.h; \
	elif [ -f /usr/include/termio.h ]; then \
	    echo '/* use termio */' >> terminal.h; \
	    echo '#undef USE_TERMIOS   /* <termios.h> */' >> terminal.h; \
	    echo '#define USE_TERMIO   /* <termio.h> */' >> terminal.h; \
	    echo '#undef USE_SGTTY     /* <sys/ioctl.h> */' >> terminal.h; \
	else \
	    echo '/* use sgtty */' >> terminal.h; \
	    echo '#undef USE_TERMIOS   /* <termios.h> */' >> terminal.h; \
	    echo '#undef USE_TERMIO    /* <termio.h> */' >> terminal.h; \
	    echo '#define USE_SGTTY    /* <sys/ioctl.h> */' >> terminal.h; \
	fi
	${Q} echo '#endif' >> terminal.h
	${Q} echo '#endif' >> terminal.h
	${Q} echo '#endif' >> terminal.h
	${Q} echo '' >> terminal.h
	${Q} echo '' >> terminal.h
	${Q} echo '#endif /* !__TERMINAL_H__ */' >> terminal.h
	${Q} echo 'terminal.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_fpos.h: have_fpos.c ${MAKE_FILE}
	${Q} ${RM} -f fpos_tmp have_fpos.h
	${Q} echo 'forming have_fpos.h'
	${Q} echo '/*' > have_fpos.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_fpos.h
	${Q} echo ' */' >> have_fpos.h
	${Q} echo '' >> have_fpos.h
	${Q} echo '' >> have_fpos.h
	${Q} echo '#if !defined(CALC_HAVE_FPOS_H)' >> have_fpos.h
	${Q} echo '#define CALC_HAVE_FPOS_H' >> have_fpos.h
	${Q} echo '' >> have_fpos.h
	${Q} echo '' >> have_fpos.h
	${Q} echo '/* do we have fgetpos & fsetpos functions? */' >> have_fpos.h
	${Q} ${RM} -f have_fpos.o have_fpos${EXT}
	-${Q} ${LCC} ${HAVE_FPOS} ${ICFLAGS} have_fpos.c -c \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_fpos.o -o have_fpos${EXT} \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_fpos${EXT} > fpos_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s fpos_tmp ]; then \
	    ${CAT} fpos_tmp >> have_fpos.h; \
	else \
	    echo '#undef HAVE_FPOS  /* no */' >> have_fpos.h; \
	    echo '' >> have_fpos.h; \
	    echo 'typedef long FILEPOS;' >> have_fpos.h; \
	fi
	${Q} echo '' >> have_fpos.h
	${Q} echo '' >> have_fpos.h
	${Q} echo '#endif /* !CALC_HAVE_FPOS_H */' >> have_fpos.h
	${Q} ${RM} -f have_fpos${EXT} have_fpos.o fpos_tmp
	${Q} echo 'have_fpos.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_fpos_pos.h: have_fpos_pos.c have_fpos.h have_posscl.h ${MAKE_FILE}
	${Q} ${RM} -f fpos_tmp have_fpos_pos.h
	${Q} echo 'forming have_fpos_pos.h'
	${Q} echo '/*' > have_fpos_pos.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' \
		>> have_fpos_pos.h
	${Q} echo ' */' >> have_fpos_pos.h
	${Q} echo '' >> have_fpos_pos.h
	${Q} echo '' >> have_fpos_pos.h
	${Q} echo '#if !defined(CALC_HAVE_FPOS_POS_H)' >> have_fpos_pos.h
	${Q} echo '#define CALC_HAVE_FPOS_POS_H' >> have_fpos_pos.h
	${Q} echo '' >> have_fpos_pos.h
	${Q} echo '' >> have_fpos_pos.h
	${Q} echo '/* do we have fgetpos & fsetpos functions? */' \
		>> have_fpos_pos.h
	${Q} ${RM} -f have_fpos_pos.o have_fpos_pos${EXT}
	-${Q} ${LCC} ${HAVE_FPOS} ${HAVE_FPOS_POS} \
		    ${ICFLAGS} have_fpos_pos.c -c >/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_fpos_pos.o -o have_fpos_pos${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_fpos_pos${EXT} > fpos_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s fpos_tmp ]; then \
	    ${CAT} fpos_tmp >> have_fpos_pos.h; \
	else \
	    echo '#undef HAVE_FPOS_POS  /* no */' >> have_fpos_pos.h; \
	    echo '' >> have_fpos_pos.h; \
	    echo '#undef FPOS_POS_BITS' >> have_fpos_pos.h; \
	fi
	${Q} echo '' >> have_fpos_pos.h
	${Q} echo '' >> have_fpos_pos.h
	${Q} echo '#endif /* !CALC_HAVE_FPOS_POS_H */' >> have_fpos_pos.h
	${Q} ${RM} -f have_fpos_pos${EXT} have_fpos_pos.o fpos_tmp
	${Q} echo 'have_fpos_pos.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

fposval.h: fposval.c have_fpos.h have_fpos_pos.h have_offscl.h have_posscl.h \
	   endian_calc.h ${MAKE_FILE}
	${Q} ${RM} -f fposv_tmp fposval.h
	${Q} echo 'forming fposval.h'
	${Q} echo '/*' > fposval.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> fposval.h
	${Q} echo ' */' >> fposval.h
	${Q} echo '' >> fposval.h
	${Q} echo '' >> fposval.h
	${Q} echo '#if !defined(__FPOSVAL_H__)' >> fposval.h
	${Q} echo '#define __FPOSVAL_H__' >> fposval.h
	${Q} echo '' >> fposval.h
	${Q} echo '' >> fposval.h
	${Q} echo '/* what are our file position & size types? */' >> fposval.h
	${Q} ${RM} -f fposval.o fposval${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${FPOS_BITS} ${OFF_T_BITS} \
		${DEV_BITS} ${INODE_BITS} fposval.c -c >/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} fposval.o -o fposval${EXT} >/dev/null \
	    2>&1; ${TRUE}
	${Q} ${SHELL} -c "./fposval${EXT} fposv_tmp >> fposval.h 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	${Q} echo '' >> fposval.h
	${Q} echo '' >> fposval.h
	${Q} echo '#endif /* !__FPOSVAL_H__ */' >> fposval.h
	${Q} ${RM} -f fposval${EXT} fposval.o fposv_tmp
	${Q} echo 'fposval.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_const.h: have_const.c ${MAKE_FILE}
	${Q} ${RM} -f have_const const_tmp have_const.h
	${Q} echo 'forming have_const.h'
	${Q} echo '/*' > have_const.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_const.h
	${Q} echo ' */' >> have_const.h
	${Q} echo '' >> have_const.h
	${Q} echo '' >> have_const.h
	${Q} echo '#if !defined(CALC_HAVE_CONST_H)' >> have_const.h
	${Q} echo '#define CALC_HAVE_CONST_H' >> have_const.h
	${Q} echo '' >> have_const.h
	${Q} echo '' >> have_const.h
	${Q} echo '/* do we have or want const? */' >> have_const.h
	${Q} ${RM} -f have_const.o have_const${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_CONST} have_const.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_const.o -o have_const${EXT} \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_const${EXT} > const_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s const_tmp ]; then \
	    ${CAT} const_tmp >> have_const.h; \
	else \
	    echo '#undef HAVE_CONST /* no */' >> have_const.h; \
	    echo '#undef CONST' >> have_const.h; \
	    echo '#define CONST /* no */' >> have_const.h; \
	fi
	${Q} echo '' >> have_const.h
	${Q} echo '' >> have_const.h
	${Q} echo '#endif /* !CALC_HAVE_CONST_H */' >> have_const.h
	${Q} ${RM} -f have_const${EXT} have_const.o const_tmp
	${Q} echo 'have_const.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_offscl.h: have_offscl.c ${MAKE_FILE}
	${Q} ${RM} -f offscl_tmp have_offscl.h
	${Q} echo 'forming have_offscl.h'
	${Q} echo '/*' > have_offscl.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_offscl.h
	${Q} echo ' */' >> have_offscl.h
	${Q} echo '' >> have_offscl.h
	${Q} echo '' >> have_offscl.h
	${Q} echo '#if !defined(CALC_HAVE_OFFSCL_H)' >> have_offscl.h
	${Q} echo '#define CALC_HAVE_OFFSCL_H' >> have_offscl.h
	${Q} echo '' >> have_offscl.h
	${Q} echo '' >> have_offscl.h
	${Q} ${RM} -f have_offscl.o have_offscl${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_OFFSCL} have_offscl.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_offscl.o -o have_offscl${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_offscl${EXT} > offscl_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s offscl_tmp ]; then \
	    ${CAT} offscl_tmp >> have_offscl.h; \
	else \
	    echo '#undef HAVE_OFF_T_SCALAR /* off_t is not a simple value */' \
		>> have_offscl.h; \
	fi
	${Q} echo '' >> have_offscl.h
	${Q} echo '' >> have_offscl.h
	${Q} echo '#endif /* !CALC_HAVE_OFFSCL_H */' >> have_offscl.h
	${Q} ${RM} -f have_offscl${EXT} have_offscl.o offscl_tmp
	${Q} echo 'have_offscl.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_posscl.h: have_posscl.c have_fpos.h ${MAKE_FILE}
	${Q} ${RM} -f have_posscl have_posscl.o posscl_tmp have_posscl.h
	${Q} echo 'forming have_posscl.h'
	${Q} echo '/*' > have_posscl.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_posscl.h
	${Q} echo ' */' >> have_posscl.h
	${Q} echo '' >> have_posscl.h
	${Q} echo '' >> have_posscl.h
	${Q} echo '#if !defined(CALC_HAVE_POSSCL_H)' >> have_posscl.h
	${Q} echo '#define CALC_HAVE_POSSCL_H' >> have_posscl.h
	${Q} echo '' >> have_posscl.h
	${Q} echo '' >> have_posscl.h
	${Q} ${RM} -f have_posscl.o have_posscl
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_POSSCL} have_posscl.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_posscl.o -o have_posscl \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_posscl > posscl_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s posscl_tmp ]; then \
	    ${CAT} posscl_tmp >> have_posscl.h; \
	else \
	    echo '/* FILEPOS is not a simple value */' >> have_posscl.h; \
	    echo '#undef HAVE_FILEPOS_SCALAR' >> have_posscl.h; \
	fi
	${Q} echo '' >> have_posscl.h
	${Q} echo '' >> have_posscl.h
	${Q} echo '#endif /* !CALC_HAVE_POSSCL_H */' >> have_posscl.h
	${Q} ${RM} -f have_posscl have_posscl.o posscl_tmp
	${Q} echo 'have_posscl.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

align32.h: align32.c longbits.h have_unistd.h ${MAKE_FILE}
	${Q} ${RM} -f align32 align32_tmp align32.h
	${Q} echo 'forming align32.h'
	${Q} echo '/*' > align32.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> align32.h
	${Q} echo ' */' >> align32.h
	${Q} echo '' >> align32.h
	${Q} echo '' >> align32.h
	${Q} echo '#if !defined(__MUST_ALIGN32_H__)' >> align32.h
	${Q} echo '#define __MUST_ALIGN32_H__' >> align32.h
	${Q} echo '' >> align32.h
	${Q} echo '' >> align32.h
	${Q} echo '/* must we always align 32 bit accesses? */' >> align32.h
	-${Q} if [ X"-DMUST_ALIGN32" = X${ALIGN32} ]; then \
	    echo '/* forced to align 32 bit values */' >> align32.h; \
	    echo '#define MUST_ALIGN32' >> align32.h; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ X"-UMUST_ALIGN32" = X${ALIGN32} ]; then \
	    echo '/* forced to not require 32 bit alignment */' >> align32.h; \
	    echo '#undef MUST_ALIGN32' >> align32.h; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ X = X${ALIGN32} ]; then \
	    ${RM} -f align32.o align32${EXT}; \
	    ${LCC} ${ICFLAGS} ${ALIGN32} align32.c -c >/dev/null 2>&1; \
	    ${LCC} ${ILDFLAGS} align32.o -o align32${EXT} >/dev/null 2>&1; \
	    ${SHELL} -c \
		  "./align32${EXT} >align32_tmp 2>/dev/null" >/dev/null 2>&1; \
	    if [ -s align32_tmp ]; then \
		${CAT} align32_tmp >> align32.h; \
	    else \
		echo '/* guess we must align 32 bit values */' >> align32.h; \
		echo '#define MUST_ALIGN32' >> align32.h; \
	    fi; \
	    ${RM} -f align32${EXT} align32.o align32_tmp core; \
	else \
	    ${TRUE}; \
	fi
	${Q} echo '' >> align32.h
	${Q} echo '' >> align32.h
	${Q} echo '#endif /* !__MUST_ALIGN32_H__ */' >> align32.h
	${Q} echo 'align32.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_uid_t.h: have_uid_t.c have_unistd.h ${MAKE_FILE}
	${Q} ${RM} -f have_uid_t uid_tmp have_uid_t.h
	${Q} echo 'forming have_uid_t.h'
	${Q} echo '/*' > have_uid_t.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_uid_t.h
	${Q} echo ' */' >> have_uid_t.h
	${Q} echo '' >> have_uid_t.h
	${Q} echo '' >> have_uid_t.h
	${Q} echo '#if !defined(CALC_HAVE_UID_T_H)' >> have_uid_t.h
	${Q} echo '#define CALC_HAVE_UID_T_H' >> have_uid_t.h
	${Q} echo '' >> have_uid_t.h
	${Q} echo '' >> have_uid_t.h
	${Q} echo '/* do we have or want uid_t? */' >> have_uid_t.h
	${Q} ${RM} -f have_uid_t.o have_uid_t${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_UID_T} have_uid_t.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_uid_t.o -o have_uid_t${EXT} \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_uid_t${EXT} > uid_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s uid_tmp ]; then \
	    ${CAT} uid_tmp >> have_uid_t.h; \
	else \
	    echo '#undef HAVE_UID_T /* no */' >> have_uid_t.h; \
	fi
	${Q} echo '' >> have_uid_t.h
	${Q} echo '' >> have_uid_t.h
	${Q} echo '#endif /* !CALC_HAVE_UID_T_H */' >> have_uid_t.h
	${Q} ${RM} -f have_uid_t${EXT} have_uid_t.o uid_tmp
	${Q} echo 'have_uid_t.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_newstr.h: have_newstr.c ${MAKE_FILE}
	${Q} ${RM} -f newstr_tmp have_newstr.h
	${Q} echo 'forming have_newstr.h'
	${Q} echo '/*' > have_newstr.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_newstr.h
	${Q} echo ' */' >> have_newstr.h
	${Q} echo '' >> have_newstr.h
	${Q} echo '' >> have_newstr.h
	${Q} echo '#if !defined(CALC_HAVE_NEWSTR_H)' >> have_newstr.h
	${Q} echo '#define CALC_HAVE_NEWSTR_H' >> have_newstr.h
	${Q} echo '' >> have_newstr.h
	${Q} echo '' >> have_newstr.h
	${Q} echo '/* do we have or want memcpy(), memset() & strchr()? */' \
							>> have_newstr.h
	${Q} ${RM} -f have_newstr.o have_newstr${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_NEWSTR} have_newstr.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_newstr.o -o have_newstr${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_newstr${EXT} > newstr_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s newstr_tmp ]; then \
	    ${CAT} newstr_tmp >> have_newstr.h; \
	else \
	    echo '#undef HAVE_NEWSTR /* no */' >> have_newstr.h; \
	fi
	${Q} echo '' >> have_newstr.h
	${Q} echo '' >> have_newstr.h
	${Q} echo '#endif /* !CALC_HAVE_NEWSTR_H */' >> have_newstr.h
	${Q} ${RM} -f have_newstr${EXT} have_newstr.o newstr_tmp
	${Q} echo 'have_newstr.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_memmv.h: have_memmv.c ${MAKE_FILE}
	${Q} ${RM} -f have_memmv have_memmv.o memmv_tmp have_memmv.h
	${Q} echo 'forming have_memmv.h'
	${Q} echo '/*' > have_memmv.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_memmv.h
	${Q} echo ' */' >> have_memmv.h
	${Q} echo '' >> have_memmv.h
	${Q} echo '' >> have_memmv.h
	${Q} echo '#if !defined(CALC_HAVE_MEMMV_H)' >> have_memmv.h
	${Q} echo '#define CALC_HAVE_MEMMV_H' >> have_memmv.h
	${Q} echo '' >> have_memmv.h
	${Q} echo '' >> have_memmv.h
	${Q} echo '/* do we have or want memmove()? */' >> have_memmv.h
	${Q} ${RM} -f have_memmv.o have_memmv
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_MEMMOVE} have_memmv.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_memmv.o -o have_memmv \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_memmv > memmv_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s memmv_tmp ]; then \
	    ${CAT} memmv_tmp >> have_memmv.h; \
	else \
	    echo '#undef HAVE_MEMMOVE /* no */' >> have_memmv.h; \
	fi
	${Q} echo '' >> have_memmv.h
	${Q} echo '' >> have_memmv.h
	${Q} echo '#endif /* !CALC_HAVE_MEMMV_H */' >> have_memmv.h
	${Q} ${RM} -f have_memmv have_memmv.o memmv_tmp
	${Q} echo 'have_memmv.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_ustat.h: have_ustat.c ${MAKE_FILE}
	${Q} ${RM} -f ustat_tmp have_ustat.h
	${Q} echo 'forming have_ustat.h'
	${Q} echo '/*' > have_ustat.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_ustat.h
	${Q} echo ' */' >> have_ustat.h
	${Q} echo '' >> have_ustat.h
	${Q} echo '' >> have_ustat.h
	${Q} echo '#if !defined(CALC_HAVE_USTAT_H)' >> have_ustat.h
	${Q} echo '#define CALC_HAVE_USTAT_H' >> have_ustat.h
	${Q} echo '' >> have_ustat.h
	${Q} echo '' >> have_ustat.h
	${Q} echo '/* do we have or want ustat()? */' >> have_ustat.h
	${Q} ${RM} -f have_ustat.o have_ustat${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_USTAT} have_ustat.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_ustat.o -o have_ustat${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_ustat${EXT} > ustat_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s ustat_tmp ]; then \
	    ${CAT} ustat_tmp >> have_ustat.h; \
	else \
	    echo '#undef HAVE_USTAT /* no */' >> have_ustat.h; \
	fi
	${Q} echo '' >> have_ustat.h
	${Q} echo '' >> have_ustat.h
	${Q} echo '#endif /* !CALC_HAVE_USTAT_H */' >> have_ustat.h
	${Q} ${RM} -f have_ustat${EXT} have_ustat.o ustat_tmp
	${Q} echo 'have_ustat.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_getsid.h: have_getsid.c ${MAKE_FILE}
	${Q} ${RM} -f getsid_tmp have_getsid.h
	${Q} echo 'forming have_getsid.h'
	${Q} echo '/*' > have_getsid.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_getsid.h
	${Q} echo ' */' >> have_getsid.h
	${Q} echo '' >> have_getsid.h
	${Q} echo '' >> have_getsid.h
	${Q} echo '#if !defined(CALC_HAVE_GETSID_H)' >> have_getsid.h
	${Q} echo '#define CALC_HAVE_GETSID_H' >> have_getsid.h
	${Q} echo '' >> have_getsid.h
	${Q} echo '' >> have_getsid.h
	${Q} echo '/* do we have or want getsid()? */' >> have_getsid.h
	${Q} ${RM} -f have_getsid.o have_getsid${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_GETSID} have_getsid.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_getsid.o -o have_getsid \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_getsid${EXT} > getsid_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s getsid_tmp ]; then \
	    ${CAT} getsid_tmp >> have_getsid.h; \
	else \
	    echo '#undef HAVE_GETSID /* no */' >> have_getsid.h; \
	fi
	${Q} echo '' >> have_getsid.h
	${Q} echo '' >> have_getsid.h
	${Q} echo '#endif /* !CALC_HAVE_GETSID_H */' >> have_getsid.h
	${Q} ${RM} -f have_getsid${EXT} have_getsid.o getsid_tmp
	${Q} echo 'have_getsid.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_getpgid.h: have_getpgid.c ${MAKE_FILE}
	${Q} ${RM} -f getpgid_tmp have_getpgid.h
	${Q} echo 'forming have_getpgid.h'
	${Q} echo '/*' > have_getpgid.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> \
	    have_getpgid.h
	${Q} echo ' */' >> have_getpgid.h
	${Q} echo '' >> have_getpgid.h
	${Q} echo '' >> have_getpgid.h
	${Q} echo '#if !defined(CALC_HAVE_GETPGID_H)' >> have_getpgid.h
	${Q} echo '#define CALC_HAVE_GETPGID_H' >> have_getpgid.h
	${Q} echo '' >> have_getpgid.h
	${Q} echo '' >> have_getpgid.h
	${Q} echo '/* do we have or want getpgid()? */' >> have_getpgid.h
	${Q} ${RM} -f have_getpgid.o have_getpgid${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_GETPGID} have_getpgid.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_getpgid.o -o have_getpgid${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_getpgid${EXT} > getpgid_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s getpgid_tmp ]; then \
	    ${CAT} getpgid_tmp >> have_getpgid.h; \
	else \
	    echo '#undef HAVE_GETPGID /* no */' >> have_getpgid.h; \
	fi
	${Q} echo '' >> have_getpgid.h
	${Q} echo '' >> have_getpgid.h
	${Q} echo '#endif /* !CALC_HAVE_GETPGID_H */' >> have_getpgid.h
	${Q} ${RM} -f have_getpgid${EXT} have_getpgid.o getpgid_tmp
	${Q} echo 'have_getpgid.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_gettime.h: have_gettime.c ${MAKE_FILE}
	${Q} ${RM} -f gettime_tmp have_gettime.h
	${Q} echo 'forming have_gettime.h'
	${Q} echo '/*' > have_gettime.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> \
	    have_gettime.h
	${Q} echo ' */' >> have_gettime.h
	${Q} echo '' >> have_gettime.h
	${Q} echo '' >> have_gettime.h
	${Q} echo '#if !defined(CALC_HAVE_GETTIME_H)' >> have_gettime.h
	${Q} echo '#define CALC_HAVE_GETTIME_H' >> have_gettime.h
	${Q} echo '' >> have_gettime.h
	${Q} echo '' >> have_gettime.h
	${Q} echo '/* do we have or want clock_gettime()? */' >> have_gettime.h
	${Q} ${RM} -f have_gettime.o have_gettime${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_GETTIME} have_gettime.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_gettime.o -o have_gettime \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_gettime${EXT} > gettime_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s gettime_tmp ]; then \
	    ${CAT} gettime_tmp >> have_gettime.h; \
	else \
	    echo '#undef HAVE_GETTIME /* no */' >> have_gettime.h; \
	fi
	${Q} echo '' >> have_gettime.h
	${Q} echo '' >> have_gettime.h
	${Q} echo '#endif /* !CALC_HAVE_GETTIME_H */' >> have_gettime.h
	${Q} ${RM} -f have_gettime${EXT} have_gettime.o gettime_tmp
	${Q} echo 'have_gettime.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_getprid.h: have_getprid.c ${MAKE_FILE}
	${Q} ${RM} -f getprid_tmp have_getprid.h
	${Q} echo 'forming have_getprid.h'
	${Q} echo '/*' > have_getprid.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> \
	    have_getprid.h
	${Q} echo ' */' >> have_getprid.h
	${Q} echo '' >> have_getprid.h
	${Q} echo '' >> have_getprid.h
	${Q} echo '#if !defined(CALC_HAVE_GETPRID_H)' >> have_getprid.h
	${Q} echo '#define CALC_HAVE_GETPRID_H' >> have_getprid.h
	${Q} echo '' >> have_getprid.h
	${Q} echo '' >> have_getprid.h
	${Q} echo '/* do we have or want getprid()? */' >> have_getprid.h
	${Q} ${RM} -f have_getprid.o have_getprid${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_GETPRID} have_getprid.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_getprid.o -o have_getprid${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_getprid${EXT} > getprid_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s getprid_tmp ]; then \
	    ${CAT} getprid_tmp >> have_getprid.h; \
	else \
	    echo '#undef HAVE_GETPRID /* no */' >> have_getprid.h; \
	fi
	${Q} echo '' >> have_getprid.h
	${Q} echo '' >> have_getprid.h
	${Q} echo '#endif /* !CALC_HAVE_GETPRID_H */' >> have_getprid.h
	${Q} ${RM} -f have_getprid${EXT} have_getprid.o getprid_tmp
	${Q} echo 'have_getprid.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_urandom.h: ${MAKE_FILE}
	${Q} ${RM} -f have_urandom.h
	${Q} echo 'forming have_urandom.h'
	${Q} echo '/*' > have_urandom.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> \
	    have_urandom.h
	${Q} echo ' */' >> have_urandom.h
	${Q} echo '' >> have_urandom.h
	${Q} echo '' >> have_urandom.h
	${Q} echo '#if !defined(CALC_HAVE_URANDOM_H)' >> have_urandom.h
	${Q} echo '#define CALC_HAVE_URANDOM_H' >> have_urandom.h
	${Q} echo '' >> have_urandom.h
	${Q} echo '' >> have_urandom.h
	${Q} echo '/* do we have /dev/urandom? */' >> have_urandom.h
	-${Q} if [ X"${HAVE_URANDOM_H}" = X"YES" ]; then \
	    echo '#define HAVE_URANDOM_H	/* yes */' >> have_urandom.h; \
	elif [ X"${HAVE_URANDOM_H}" = X"NO" ]; then \
	    echo '#undef HAVE_URANDOM_H  /* no */' >> have_urandom.h; \
	elif [ -r /dev/urandom ] 2>/dev/null; then \
	    echo '#define HAVE_URANDOM_H  /* yes */' >> have_urandom.h; \
	else \
	    echo '#undef HAVE_URANDOM_H	 /* no */' >> have_urandom.h; \
	fi
	${Q} echo '' >> have_urandom.h
	${Q} echo '' >> have_urandom.h
	${Q} echo '#endif /* !CALC_HAVE_URANDOM_H */' >> have_urandom.h
	${Q} echo 'have_urandom.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_rusage.h: have_rusage.c ${MAKE_FILE}
	${Q} ${RM} -f rusage_tmp have_rusage.h
	${Q} echo 'forming have_rusage.h'
	${Q} echo '/*' > have_rusage.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> \
	    have_rusage.h
	${Q} echo ' */' >> have_rusage.h
	${Q} echo '' >> have_rusage.h
	${Q} echo '' >> have_rusage.h
	${Q} echo '#if !defined(CALC_HAVE_RUSAGE_H)' >> have_rusage.h
	${Q} echo '#define CALC_HAVE_RUSAGE_H' >> have_rusage.h
	${Q} echo '' >> have_rusage.h
	${Q} echo '' >> have_rusage.h
	${Q} echo '/* do we have or want getrusage()? */' >> have_rusage.h
	${Q} ${RM} -f have_rusage.o have_rusage${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_GETRUSAGE} have_rusage.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_rusage.o -o have_rusage${EXT} \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_rusage${EXT} > rusage_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s rusage_tmp ]; then \
	    ${CAT} rusage_tmp >> have_rusage.h; \
	else \
	    echo '#undef HAVE_GETRUSAGE /* no */' >> have_rusage.h; \
	fi
	${Q} echo '' >> have_rusage.h
	${Q} echo '' >> have_rusage.h
	${Q} echo '#endif /* !CALC_HAVE_RUSAGE_H */' >> have_rusage.h
	${Q} ${RM} -f have_rusage${EXT} have_rusage.o rusage_tmp
	${Q} echo 'have_rusage.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_strdup.h: have_strdup.c ${MAKE_FILE}
	${Q} ${RM} -f strdup_tmp have_strdup.h
	${Q} echo 'forming have_strdup.h'
	${Q} echo '/*' > have_strdup.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_strdup.h
	${Q} echo ' */' >> have_strdup.h
	${Q} echo '' >> have_strdup.h
	${Q} echo '' >> have_strdup.h
	${Q} echo '#if !defined(CALC_HAVE_STRDUP_H)' >> have_strdup.h
	${Q} echo '#define CALC_HAVE_STRDUP_H' >> have_strdup.h
	${Q} echo '' >> have_strdup.h
	${Q} echo '' >> have_strdup.h
	${Q} echo '/* do we have or want getstrdup()? */' >> have_strdup.h
	${Q} ${RM} -f have_strdup.o have_strdup${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_STRDUP} have_strdup.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_strdup.o -o have_strdup \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_strdup${EXT} > strdup_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s strdup_tmp ]; then \
	    ${CAT} strdup_tmp >> have_strdup.h; \
	else \
	    echo '#undef HAVE_STRDUP /* no */' >> have_strdup.h; \
	fi
	${Q} echo '' >> have_strdup.h
	${Q} echo '' >> have_strdup.h
	${Q} echo '#endif /* !CALC_HAVE_STRDUP_H */' >> have_strdup.h
	${Q} ${RM} -f have_strdup${EXT} have_strdup.o strdup_tmp
	${Q} echo 'have_strdup.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

args.h: have_stdvs.c have_varvs.c have_string.h have_unistd.h have_string.h
	${Q} ${RM} -f args.h
	${Q} echo 'forming args.h'
	${Q} echo '/*' > args.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> args.h
	${Q} echo ' */' >> args.h
	${Q} echo '' >> args.h
	${Q} echo '' >> args.h
	${Q} echo '#if !defined(__ARGS_H__)' >> args.h
	${Q} echo '#define __ARGS_H__' >> args.h
	${Q} echo '' >> args.h
	${Q} echo '' >> args.h
	${Q} ${RM} -f have_stdvs.o have_stdvs${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_VSPRINTF} have_stdvs.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_stdvs.o -o have_stdvs${EXT} \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if ./have_stdvs${EXT} >>args.h 2>/dev/null; then \
	    ${TOUCH} have_args.sh; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -f have_args.sh ] && [ X"${HAVE_VSPRINTF}" = X ]; then \
	    ${RM} -f have_stdvs.o have_stdvs${EXT} have_varvs.o; \
	    ${RM} -f have_varvs${EXT}; \
	    ${LCC} ${ICFLAGS} ${HAVE_VSPRINTF} have_varvs.c -c \
		    2>/dev/null; \
	    ${LCC} ${ILDFLAGS} have_varvs.o -o have_varvs${EXT} 2>/dev/null; \
	    if ./have_varvs${EXT} >>args.h 2>/dev/null; then \
		${TOUCH} have_args.sh; \
	    else \
		${TRUE}; \
	    fi; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ -f have_args.sh ]; then \
	    echo 'exit 0' > have_args.sh; \
	else \
	    echo 'exit 1' > have_args.sh; \
	    echo "Unable to determine what type of variable args and"; \
	    echo "what type of vsprintf() should be used.  Set or change"; \
	    echo "the Makefile variable HAVE_VSPRINTF."; \
	fi
	${Q} sh ./have_args.sh
	${Q} echo '' >> args.h
	${Q} echo '' >> args.h
	${Q} echo '#endif /* !__ARGS_H__ */' >> args.h
	${Q} ${RM} -f have_stdvs.o have_varvs.o have_varvs${EXT} have_args.sh
	${Q} ${RM} -f core
	${Q} echo 'args.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

calcerr.h: calcerr.tbl calcerr_h.sed calcerr_h.awk ${MAKE_FILE}
	${Q} ${RM} -f calerr.h
	${Q} echo 'forming calcerr.h'
	${Q} echo '/*' > calcerr.h
	${Q} echo ' * DO NOT EDIT' >> calcerr.h
	${Q} echo ' *' >> calcerr.h
	${Q} echo ' * generated by calcerr.tbl via Makefile' >> calcerr.h
	${Q} echo ' */' >> calcerr.h
	${Q} echo '' >> calcerr.h
	${Q} echo '' >> calcerr.h
	${Q} echo '#if !defined(__CALCERR_H__)' >> calcerr.h
	${Q} echo '#define __CALCERR_H__' >> calcerr.h
	${Q} echo '' >> calcerr.h
	${Q} echo '' >> calcerr.h
	${Q} ${SED} -f calcerr_h.sed < calcerr.tbl | \
	    ${AWK} -f calcerr_h.awk >> calcerr.h
	${Q} echo '' >> calcerr.h
	${Q} echo '' >> calcerr.h
	${Q} echo '#endif /* !__CALCERR_H__ */' >> calcerr.h
	${Q} echo 'calcerr.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

calcerr.c: calcerr.tbl calcerr_c.sed calcerr_c.awk ${MAKE_FILE}
	${Q} ${RM} -f calerr.c
	${Q} echo 'forming calcerr.c'
	${Q} echo '/*' > calcerr.c
	${Q} echo ' * DO NOT EDIT' >> calcerr.c
	${Q} echo ' *' >> calcerr.c
	${Q} echo ' * generated by calcerr.tbl via Makefile' >> calcerr.c
	${Q} echo ' */' >> calcerr.c
	${Q} echo '' >> calcerr.c
	${Q} ${SED} -f calcerr_c.sed < calcerr.tbl | \
	    ${AWK} -f calcerr_c.awk >> calcerr.c
	${Q} echo 'calcerr.c formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

have_unused.h: have_unused.c ${MAKE_FILE}
	${Q} ${RM} -f unused_tmp have_unused.h
	${Q} echo 'forming have_unused.h'
	${Q} echo '/*' > have_unused.h
	${Q} echo ' * DO NOT EDIT -- generated by the Makefile' >> have_unused.h
	${Q} echo ' */' >> have_unused.h
	${Q} echo '' >> have_unused.h
	${Q} echo '' >> have_unused.h
	${Q} echo '#if !defined(CALC_HAVE_UNUSED_H)' >> have_unused.h
	${Q} echo '#define CALC_HAVE_UNUSED_H' >> have_unused.h
	${Q} echo '' >> have_unused.h
	${Q} echo '' >> have_unused.h
	${Q} echo '/* do we have/want the unused attribute? */' >> have_unused.h
	${Q} ${RM} -f have_unused.o have_unused${EXT}
	-${Q} ${LCC} ${ICFLAGS} ${HAVE_UNUSED} have_unused.c -c \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${LCC} ${ILDFLAGS} have_unused.o -o have_unused \
		>/dev/null 2>&1; ${TRUE}
	-${Q} ${SHELL} -c "./have_unused${EXT} > unused_tmp 2>/dev/null" \
	    >/dev/null 2>&1; ${TRUE}
	-${Q} if [ -s unused_tmp ]; then \
	    ${CAT} unused_tmp >> have_unused.h; \
	else \
	    echo '#undef HAVE_UNUSED /* no */' >> have_unused.h; \
	    echo '#undef UNUSED' >> have_unused.h; \
	    echo '#define UNUSED /* no */' >> have_unused.h; \
	fi
	${Q} echo '' >> have_unused.h
	${Q} echo '' >> have_unused.h
	${Q} echo '#endif /* !CALC_HAVE_UNUSED_H */' >> have_unused.h
	${Q} ${RM} -f have_unused${EXT} have_unused.o unused_tmp
	${Q} echo 'have_unused.h formed'
	-@if [ -z "${Q}" ]; then \
	    echo ''; \
	    echo '=-=-= start of $@ =-=-='; \
	    ${CAT} $@; \
	    echo '=-=-= end of $@ =-=-='; \
	    echo ''; \
	else \
	    ${TRUE}; \
	fi

###
#
# Build .h files for windoz based systems
#
# This is really a internal utility rule that is used to create the
# win32 sub-directory for distribution.
#
###

win32_hsrc: win32.mkdef ${MAKE_FILE}
	${Q} echo 'forming win32 directory'
	${Q} ${RM} -rf win32
	${Q} ${MKDIR} -p win32
	${Q} ${CP} ${UTIL_C_SRC} win32
	${Q} ${CP} ${UTIL_MISC_SRC} win32
	${Q} ${CP} ${MAKE_FILE} win32/${MAKE_FILE}
	${Q} (cd win32; \
	 echo "${MAKE} -f ${MAKE_FILE} hsrc `${CAT} win32.mkdef` EXT="; \
	 ${MAKE} -f ${MAKE_FILE} hsrc `${CAT} win32.mkdef` EXT=; \
	 ${RM} -f ${UTIL_C_SRC}; \
	 ${RM} -f ${UTIL_MISC_SRC}; \
	 ${RM} -f ${UTIL_OBJS}; \
	 ${RM} -f ${UTIL_PROGS}; \
	 ${RM} -f ${UTIL_FILES}; \
	 ${RM} -f ${MAKE_FILE})
	${Q} echo 'win32 directory formed'

###
#
# These rules are used in the process of building the BUILD_H_SRC.
#
###

endian.o: endian.c have_unistd.h
	${LCC} ${ICFLAGS} ${CALC_BYTE_ORDER} endian.c -c

endian${EXT}: endian.o
	${RM} -f $@
	${LCC} ${ICFLAGS} endian.o -o $@

longbits.o: longbits.c have_unistd.h
	${LCC} ${ICFLAGS} longbits.c -c

longbits${EXT}: longbits.o
	${RM} -f $@
	${LCC} ${ICFLAGS} longbits.o -o $@

###
#
# These two .all rules are used to determine of the lower level
# directory has had its all rule performed.
#
###

cal/.all: cal/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking all rule for cal =-=-=-=-='
	${RM} -f $@
	cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} all
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

help/.all: help/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking all rule for help =-=-=-=-='
	${RM} -f $@
	cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} all
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

help/builtin: help/Makefile \
	      func.c help/builtin.top help/builtin.end help/funclist.sed
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking builtin rule for help =-=-=-=-='
	${RM} -f $@
	cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} builtin
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

cscript/.all: ${CSCRIPT_TARGETS}

${CSCRIPT_TARGETS}: cscript/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking all rule for cscript =-=-=-=-='
	${RM} -f cscript/.all
	cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} all
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
custom/.all: custom/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking all rule for custom =-=-=-=-='
	${RM} -f $@
	cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} all
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

custom/libcustcalc${LIB_EXT_VERSION}: custom/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking all rule for custom =-=-=-=-='
	cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} $@
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

libcustcalc${LIB_EXT_VERSION}: custom/libcustcalc${LIB_EXT_VERSION}
	${Q} ${RM} -f $@
	${CP} -p $? $@

libcustcalc${LIB_EXT}: libcustcalc${LIB_EXT_VERSION}
	${Q} ${RM} -f $@
	${LN} -s $? $@
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */

###
#
# building calc-static and static lib*.a libraries
#
###

calc-static${EXT}: .hsrc ${CALCOBJS} \
		   ${CALC_STATIC_LIBS} ${MAKE_FILE}
	${RM} -f $@
	${CC} ${LDFLAGS} ${CALCOBJS} ${LD_STATIC} ${CALC_STATIC_LIBS} \
	      ${READLINE_LIB} ${READLINE_EXTRAS} -o $@

libcustcalc.a: custom/libcustcalc.a
	${Q} ${RM} -f $@
	${CP} -f $? $@

libcalc.a: ${LIBOBJS} ${MAKE_FILE}
	${RM} -f libcalc.a
	${AR} qc libcalc.a ${LIBOBJS}
	${RANLIB} libcalc.a
	${CHMOD} 0644 libcalc.a

#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
custom/libcustcalc.a: custom/Makefile
	cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} libcustcalc.a
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */

sample_rand-static${EXT}: sample_rand.o ${CALC_STATIC_LIBS} ${MAKE_FILE}
	${CC} ${LDFLAGS} sample_rand.o ${LD_STATIC} \
	      ${CALC_STATIC_LIBS} ${READLINE_LIB} ${READLINE_EXTRAS} -o $@

sample_many-static${EXT}: sample_many.o ${CALC_STATIC_LIBS} ${MAKE_FILE}
	${CC} ${LDFLAGS} sample_many.o ${LD_STATIC} \
	      ${CALC_STATIC_LIBS} ${READLINE_LIB} ${READLINE_EXTRAS} -o $@

###
#
# Homegrown make dependency rules.  Your system may not support
# or have the needed tools.  You can ignore this section.
#
# We will form a skeleton tree of *.c files containing only #include "foo.h"
# lines and .h files containing the same lines surrounded by multiple include
# prevention lines.  This allows us to build a static depend list that will
# satisfy all possible cpp symbol definition combinations.
#
###

depend: custom/Makefile hsrc
	${Q} if [ -f ${MAKE_FILE}.bak ]; then \
		echo "${MAKE_FILE}.bak exists, remove or move it"; \
		exit 1; \
	else \
	    ${TRUE}; \
	fi
	${V} echo '=-=-=-=-= Invoking depend rule for cscript =-=-=-=-='
	${Q} cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} depend
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking depend rule for custom =-=-=-=-='
	${Q} cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} depend
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${Q} echo forming skel
	${Q} ${RM} -rf skel
	${Q} ${MKDIR} -p skel
	-${Q} for i in ${C_SRC} ${BUILD_C_SRC}; do \
	    ${SED} -n '/^#[	 ]*include[	 ]*"/p' "$$i" | \
	    ${GREP} -v '\.\./getopt/getopt\.h' > "skel/$$i"; \
	done
	${Q} ${MKDIR} -p skel/custom
	-${Q} for i in ${H_SRC} ${BUILD_H_SRC} custom.h /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
		tag="`echo $$i | ${SED} 's/[\.+,:]/_/g'`"; \
		echo "#if !defined($$tag)" > "skel/$$i"; \
		echo "#define $$tag" >> "skel/$$i"; \
		${SED} -n '/^#[	 ]*include[	 ]*"/p' "$$i" | \
		    LANG=C ${SORT} -u >> "skel/$$i"; \
		echo '#endif /* '"$$tag"' */' >> "skel/$$i"; \
	    fi; \
	done
	${Q} ${RM} -f skel/makedep.out
	${Q} echo skel formed
	${Q} echo forming dependency list
	${Q} :> skel/makedep.out
	${Q} cd skel; \
	    ${MAKEDEPEND} -w 1 -f makedep.out ${C_SRC} ${BUILD_C_SRC}
	-${Q} for i in ${C_SRC} ${BUILD_C_SRC} /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
	      echo "$$i" | ${SED} 's/^\(.*\)\.c/\1.o: \1.c/'; \
	    fi; \
	done >> skel/makedep.out
	${Q} LANG=C ${SORT} -u skel/makedep.out -o skel/makedep.out
	${Q} echo dependency list formed
	${Q} echo forming new ${MAKE_FILE}
	${Q} ${RM} -f ${MAKE_FILE}.bak
	${Q} ${MV} ${MAKE_FILE} ${MAKE_FILE}.bak
	${Q} ${SED} -n '1,/^# DO NOT DELETE THIS LINE/p' \
		    ${MAKE_FILE}.bak > ${MAKE_FILE}
	${Q} ${GREP} -v '^#' skel/makedep.out >> ${MAKE_FILE}
	${Q} ${RM} -rf skel
	-${Q} if ${CMP} -s ${MAKE_FILE}.bak ${MAKE_FILE}; then \
	    echo 'top level ${MAKE_FILE} was already up to date'; \
	    ${MV} -f ${MAKE_FILE}.bak ${MAKE_FILE}; \
	else \
	    ${RM} -f ${MAKE_FILE}.tmp; \
	    ${MV} ${MAKE_FILE} ${MAKE_FILE}.tmp; \
	    if [ -d RCS -a ! -w "${MAKE_FILE}" ]; then \
		${CO} -l ${MAKE_FILE}; \
	    fi ;\
	    ${MV} ${MAKE_FILE}.tmp ${MAKE_FILE}; \
	    if [ -d RCS ]; then \
	    echo '********************************************************'; \
	    echo 'new top level ${MAKE_FILE} formed -- need to check it in'; \
	    echo '********************************************************'; \
	    fi; \
	fi

# generate the list of h files for lower level depend use
#
h_list:
	-${Q} for i in ${H_SRC} ${BUILD_H_SRC} /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
		echo $$i; \
	    fi; \
	done

###
#
# calc version
#
# calc_version:
#	This rule is the most accurate as it uses calc source to
#	produce the version value.  This rule produces a full
#	version string.  Note that the full version could be 4
#	or 3 levels long depending on the minor patch number.
#
# version:
#	This rule simply echoes the value found in this makefile.
#	This rule produces the full version string.  Note that the
#	full version could be 4 or 3 levels long depending on the
#	minor patch number.
#
###

calc_version: ver_calc${EXT}
	@./ver_calc${EXT}

version:
	@echo ${VERSION}

ver_calc${EXT}: version.c have_unused.h
	${RM} -f $@
	${LCC} ${ICFLAGS} -DCALC_VER ${ILDFLAGS} version.c -o $@

###
#
# File distribution list generation.  You can ignore this section.
#
# We will form the names of source files as if they were in a
# sub-directory called calc.
#
###

distlist: custom/Makefile ${DISTLIST}
	${Q} (for i in ${DISTLIST} /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
		echo $$i; \
	    fi; \
	done; \
	for i in ${BUILD_H_SRC} ${BUILD_C_SRC} /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
		echo win32/$$i; \
	    fi; \
	done; \
	(cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} $@); \
	(cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} $@); \
	(cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} $@); \
	(cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} $@) \
	) | LANG=C ${SORT}

distdir: custom/Makefile
	${Q} (echo .; \
	echo win32; \
	(cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} $@); \
	(cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} $@); \
	(cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} $@); \
	(cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} $@) \
	) | LANG=C ${SORT}

calcliblist: custom/Makefile
	${Q} (for i in ${CALCLIBLIST} /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
		echo $$i; \
	    fi; \
	done; \
	(cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} $@); \
	(cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} $@); \
	(cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} $@); \
	(cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} $@) \
	) | LANG=C ${SORT}

calcliblistfmt:
	${Q} ${MAKE} -f Makefile calcliblist | \
	    ${FMT} -64 | ${SED} -e 's/^/	/'

#if 0	/* start of skip for non-Gnu makefiles */
custom/Makefile: ${MAKE_FILE} custom/Makefile.head custom/Makefile.tail
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${Q} ${RM} -f $@
	${Q} ${CAT} custom/Makefile.head > $@
	${Q} ${SED} -n -e \
	    "/^# start of host target cut/,/^# end of host target cut/p" \
	    ${MAKE_FILE} >> $@
	${Q} ${CAT} custom/Makefile.tail >> $@
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

Makefile.simple: ${MAKE_FILE} custom/Makefile.simple
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${Q} ${RM} -f $@
	${Q} ${AWK} '/^#if 0/{skp=1} {if(!skp){print $$0}} /^#endif/{skp=0}' \
	    ${MAKE_FILE} | \
	    ${SED} -e 's/cd custom; $${MAKE} -f Makefile/&.simple/g' > $@
	${Q} echo >> $@
	${Q} echo 'Makefile.simple:' >> $@
	${Q} echo '	$${Q} if [ ! -f Makefile.simple ]; then '"\\" >> $@
	${Q} echo '		$${CP} -f $${MAKE_FILE} $$@; fi' >> $@
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

custom/Makefile.simple: custom/Makefile
	${Q} cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} Makefile.simple
#endif	/* end of skip for non-Gnu makefiles */

###
#
# Doing a 'make check' will cause the regression test suite to be executed.
# This rule will try to build anything that needs to be built as well.
#
# Doing a 'make chk' will cause only the context around interesting
# (and error) messages to be printed.  Unlike 'make check', this
# rule does not cause things to be built.  i.e., the all rule is
# not invoked.
#
###

check: all ./cal/regress.cal
	${CALC_ENV} ./calc${EXT} -d -q read regress

chk: ./cal/regress.cal
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${CALC_ENV} ./calc${EXT} -d -q read regress 2>&1 | ${AWK} -f check.awk
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

###
#
# debug
#
# make env:
#	* print major Makefile variables
#
# make mkdebug:
#	* print major Makefile variables
#	* build anything not yet built
#
# make debug:
#	* remove everything that was previously built
#	* print major Makefile variables
#	* make everything
#	* run the regression tests
###

env:
	@echo '=-=-=-=-= dumping major make variables =-=-=-=-='
	@echo 'ALIGN32=${ALIGN32}'; echo ''
	@echo 'ALLOW_CUSTOM=${ALLOW_CUSTOM}'; echo ''
	@echo 'AR=${AR}'; echo ''
	@echo 'AWK=${AWK}'; echo ''
	@echo 'BINDIR=${BINDIR}'; echo ''
	@echo 'BLD_TYPE=${BLD_TYPE}'; echo ''
	@echo 'BUILD_C_SRC=${BUILD_C_SRC}'; echo ''
	@echo 'BUILD_H_SRC=${BUILD_H_SRC}'; echo ''
	@echo 'BYTE_ORDER=${BYTE_ORDER}'; echo ''
	@echo 'CALCLIBLIST=${CALCLIBLIST}'; echo ''
	@echo 'CALCOBJS=${CALCOBJS}'; echo ''
	@echo 'CALCPAGER=${CALCPAGER}'; echo ''
	@echo 'CALCPATH=${CALCPATH}'; echo ''
	@echo 'CALCRC=${CALCRC}'; echo ''
	@echo 'CALCSRC=${CALCSRC}'; echo ''
	@echo 'CALC_DYNAMIC_LIBS=${CALC_DYNAMIC_LIBS}'; echo ''
	@echo 'CALC_ENV=${CALC_ENV}'; echo ''
	@echo 'CALC_INCDIR=${CALC_INCDIR}'; echo ''
	@echo 'CALC_SHAREDIR=${CALC_SHAREDIR}'; echo ''
	@echo 'CALC_STATIC_LIBS=${CALC_STATIC_LIBS}'; echo ''
	@echo 'CAL_PASSDOWN=${CAL_PASSDOWN}'; echo ''
	@echo 'CAT=${CAT}'; echo ''
	@echo 'CATDIR=${CATDIR}'; echo ''
	@echo 'CATEXT=${CATEXT}'; echo ''
	@echo 'CATMODE=${CATMODE}'; echo ''
	@echo 'CC=${CC}'; echo ''
	@echo 'CCMISC=${CCMISC}'; echo ''
	@echo 'CCOPT=${CCOPT}'; echo ''
	@echo 'CCWARN=${CCWARN}'; echo ''
	@echo 'CCWERR=${CCWERR}'; echo ''
	@echo 'CFLAGS=${CFLAGS}'; echo ''
	@echo 'CHMOD=${CHMOD}'; echo ''
	@echo 'CMP=${CMP}'; echo ''
	@echo 'CO=${CO}'; echo ''
	@echo 'COL=${COL}'; echo ''
	@echo 'COMMON_ADD=${COMMON_ADD}'; echo ''
	@echo 'COMMON_CFLAGS=${COMMON_CFLAGS}'; echo ''
	@echo 'COMMON_LDFLAGS=${COMMON_LDFLAGS}'; echo ''
	@echo 'CP=${CP}'; echo ''
	@echo 'CSCRIPT_PASSDOWN=${CSCRIPT_PASSDOWN}'; echo ''
	@echo 'CSCRIPT_TARGETS=${CSCRIPT_TARGETS}'; echo ''
	@echo 'CTAGS=${CTAGS}'; echo ''
	@echo 'CUSTOMCALDIR=${CUSTOMCALDIR}'; echo ''
	@echo 'CUSTOMHELPDIR=${CUSTOMHELPDIR}'; echo ''
	@echo 'CUSTOMINCDIR=${CUSTOMINCDIR}'; echo ''
	@echo 'CUSTOM_PASSDOWN=${CUSTOM_PASSDOWN}'; echo ''
	@echo 'C_SRC=${C_SRC}'; echo ''
	@echo 'DEBUG=${DEBUG}'; echo ''
	@echo 'DEFAULT_LIB_INSTALL_PATH=${DEFAULT_LIB_INSTALL_PATH}'; echo ''
	@echo 'DEV_BITS=${DEV_BITS}'; echo ''
	@echo 'DIFF=${DIFF}'; echo ''
	@echo 'DISTLIST=${DISTLIST}'; echo ''
	@echo 'EXT=${EXT}'; echo ''
	@echo 'FMT=${FMT}'; echo ''
	@echo 'FPOS_BITS=${FPOS_BITS}'; echo ''
	@echo 'FPOS_POS_BITS=${FPOS_POS_BITS}'; echo ''
	@echo 'GREP=${GREP}'; echo ''
	@echo 'HAVE_CONST=${HAVE_CONST}'; echo ''
	@echo 'HAVE_FPOS=${HAVE_FPOS}'; echo ''
	@echo 'HAVE_FPOS_POS=${HAVE_FPOS_POS}'; echo ''
	@echo 'HAVE_GETPGID=${HAVE_GETPGID}'; echo ''
	@echo 'HAVE_GETPRID=${HAVE_GETPRID}'; echo ''
	@echo 'HAVE_GETRUSAGE=${HAVE_GETRUSAGE}'; echo ''
	@echo 'HAVE_GETSID=${HAVE_GETSID}'; echo ''
	@echo 'HAVE_GETTIME=${HAVE_GETTIME}'; echo ''
	@echo 'HAVE_MEMMOVE=${HAVE_MEMMOVE}'; echo ''
	@echo 'HAVE_NEWSTR=${HAVE_NEWSTR}'; echo ''
	@echo 'HAVE_OFFSCL=${HAVE_OFFSCL}'; echo ''
	@echo 'HAVE_POSSCL=${HAVE_POSSCL}'; echo ''
	@echo 'HAVE_STDLIB_H=${HAVE_STDLIB_H}'; echo ''
	@echo 'HAVE_STRDUP=${HAVE_STRDUP}'; echo ''
	@echo 'HAVE_STRING_H=${HAVE_STRING_H}'; echo ''
	@echo 'HAVE_SYS_TIMES_H=${HAVE_SYS_TIMES_H}'; echo ''
	@echo 'HAVE_SYS_TIME_H=${HAVE_SYS_TIME_H}'; echo ''
	@echo 'HAVE_TIMES_H=${HAVE_TIMES_H}'; echo ''
	@echo 'HAVE_TIME_H=${HAVE_TIME_H}'; echo ''
	@echo 'HAVE_UID_T=${HAVE_UID_T}'; echo ''
	@echo 'HAVE_UNISTD_H=${HAVE_UNISTD_H}'; echo ''
	@echo 'HAVE_UNUSED=${HAVE_UNUSED}'; echo ''
	@echo 'HAVE_URANDOM_H=${HAVE_URANDOM_H}'; echo ''
	@echo 'HAVE_USTAT=${HAVE_USTAT}'; echo ''
	@echo 'HAVE_VSPRINTF=${HAVE_VSPRINTF}'; echo ''
	@echo 'HELPDIR=${HELPDIR}'; echo ''
	@echo 'HELP_PASSDOWN=${HELP_PASSDOWN}'; echo ''
	@echo 'H_SRC=${H_SRC}'; echo ''
	@echo 'ICFLAGS=${ICFLAGS}'; echo ''
	@echo 'ILDFLAGS=${ILDFLAGS}'; echo ''
	@echo 'INCDIR=${INCDIR}'; echo ''
	@echo 'INODE_BITS=${INODE_BITS}'; echo ''
	@echo 'LANG=${LANG}'; echo ''
	@echo 'LCC=${LCC}'; echo ''
	@echo 'LDCONFIG=${LDCONFIG}'; echo ''
	@echo 'LDFLAGS=${LDFLAGS}'; echo ''
	@echo 'LDFLAGS=${LDFLAGS}'; echo ''
	@echo 'LD_DEBUG=${LD_DEBUG}'; echo ''
	@echo 'LD_SHARE=${LD_SHARE}'; echo ''
	@echo 'LIBCALC_SHLIB=${LIBCALC_SHLIB}'; echo ''
	@echo 'LIBCUSTCALC_SHLIB=${LIBCUSTCALC_SHLIB}'; echo ''
	@echo 'LIBDIR=${LIBDIR}'; echo ''
	@echo 'LIBOBJS=${LIBOBJS}'; echo ''
	@echo 'LIBSRC=${LIBSRC}'; echo ''
	@echo 'LIB_H_SRC=${LIB_H_SRC}'; echo ''
	@echo 'LICENSE=${LICENSE}'; echo ''
	@echo 'LN=${LN}'; echo ''
	@echo 'LONG_BITS=${LONG_BITS}'; echo ''
	@echo 'MAKE=${MAKE}'; echo ''
	@echo 'MAKEDEPEND=${MAKEDEPEND}'; echo ''
	@echo 'MAKEFILE_REV=${MAKEFILE_REV}'; echo ''
	@echo 'MAKE_FILE=${MAKE_FILE}'; echo ''
	@echo 'MANDIR=${MANDIR}'; echo ''
	@echo 'MANEXT=${MANEXT}'; echo ''
	@echo 'MANMAKE=${MANMAKE}'; echo ''
	@echo 'MANMODE=${MANMODE}'; echo ''
	@echo 'MKDIR=${MKDIR}'; echo ''
	@echo 'MV=${MV}'; echo ''
	@echo 'NROFF=${NROFF}'; echo ''
	@echo 'NROFF_ARG=${NROFF_ARG}'; echo ''
	@echo 'OBJS=${OBJS}'; echo ''
	@echo 'OFF_T_BITS=${OFF_T_BITS}'; echo ''
	@echo 'PURIFY=${PURIFY}'; echo ''
	@echo 'Q=${Q}'; echo ''
	@echo 'RANLIB=${RANLIB}'; echo ''
	@echo 'READLINE_EXTRAS=${READLINE_EXTRAS}'; echo ''
	@echo 'READLINE_INCLUDE=${READLINE_INCLUDE}'; echo ''
	@echo 'READLINE_LIB=${READLINE_LIB}'; echo ''
	@echo 'RM=${RM}'; echo ''
	@echo 'RMDIR=${RMDIR}'; echo ''
	@echo 'SAMPLE_C_SRC=${SAMPLE_C_SRC}'; echo ''
	@echo 'SAMPLE_H_SRC=${SAMPLE_H_SRC}'; echo ''
	@echo 'SAMPLE_OBJ=${SAMPLE_OBJ}'; echo ''
	@echo 'SAMPLE_STATIC_TARGETS=${SAMPLE_STATIC_TARGETS}'; echo ''
	@echo 'SAMPLE_TARGETS=${SAMPLE_TARGETS}'; echo ''
	@echo 'SCRIPTDIR=${SCRIPTDIR}'; echo ''
	@echo 'SED=${SED}'; echo ''
	@echo 'SHELL=${SHELL}'; echo ''
	@echo 'SORT=${SORT}'; echo ''
	@echo 'SPLINT=${SPLINT}'; echo ''
	@echo 'SPLINT_OPTS=${SPLINT_OPTS}'; echo ''
	@echo 'SYM_DYNAMIC_LIBS=${SYM_DYNAMIC_LIBS}'; echo ''
	@echo 'T=${T}'; echo ''
	@echo 'TARGETS=${TARGETS}'; echo ''
	@echo 'TEE=${TEE}'; echo ''
	@echo 'TERMCONTROL=${TERMCONTROL}'; echo ''
	@echo 'TOP_MAKE_FILE=${TOP_MAKE_FILE}'; echo ''
	@echo 'TOUCH=${TOUCH}'; echo ''
	@echo 'TRUE=${TRUE}'; echo ''
	@echo 'USE_READLINE=${USE_READLINE}'; echo ''
	@echo 'UTIL_C_SRC=${UTIL_C_SRC}'; echo ''
	@echo 'UTIL_MISC_SRC=${UTIL_MISC_SRC}'; echo ''
	@echo 'UTIL_OBJS=${UTIL_OBJS}'; echo ''
	@echo 'UTIL_FILES=${UTIL_FILES}'; echo ''
	@echo 'UTIL_PROGS=${UTIL_PROGS}'; echo ''
	@echo 'UTIL_TMP=${UTIL_TMP}'; echo ''
	@echo 'V=${V}'; echo ''
	@echo 'VERSION=${VERSION}'; echo ''
	@echo 'XARGS=${XARGS}'; echo ''
	@echo 'target=${target}'; echo ''
	@echo '=-=-=-=-= ${MAKE_FILE} end of major make variable dump =-=-=-=-='

mkdebug: env version.c
	@echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	@echo '=-=-=-= Determining the source version =-=-=-='
	@${MAKE} -f Makefile Q= V=@ ver_calc${EXT}
	-@./ver_calc${EXT}
	@echo '=-=-=-= Invoking ${MAKE} -f Makefile Q= V=@ all =-=-=-='
	@${MAKE} -f Makefile Q= V=@ all
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo '=-=-=-= Determining the binary version =-=-=-='
	-@./calc${EXT} -e -q -v
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

debug: env
	@echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	@echo '=-=-=-= Invoking ${MAKE} -f Makefile Q= V=@ clobber =-=-=-='
	@${MAKE} -f Makefile Q= V=@ clobber
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo '=-=-=-= Invoking ${MAKE} -f Makefile Q= V=@ all =-=-=-='
	@echo '=-=-= this may take a bit of time =-=-='
	@${MAKE} -f Makefile Q= V=@ all
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo '=-=-=-= Determining the source version =-=-=-='
	@${MAKE} -f Makefile Q= V=@ ver_calc${EXT}
	-@./ver_calc${EXT}
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo -n '=-=-=-= Print #defile values if custom functions '
	@echo 'are allowed =-=-=-='
	-@./calc${EXT} -e -q -C 'print custom("sysinfo", 2);'
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo '=-=-=-= Invoking ${MAKE} -f Makefile Q= V=@ check =-=-=-='
	@echo '=-=-= this may take a while =-=-='
	@${MAKE} -f Makefile Q= V=@ check
	@echo '=-=-=-= Back to the main Makefile for $@ rule =-=-=-='
	@echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

###
#
# testing rules
#
# make run
#	* only run calc interactively with the ${CALC_ENV} environment
#
# make dbx
#	* run the dbx debugger on calc with the ${CALC_ENV} environment
#
# make gdb
#	* run the gdb debugger on calc with the ${CALC_ENV} environment
#
###

run:
	${CALC_ENV} ./calc${EXT}

dbx:
	${CALC_ENV} dbx ./calc${EXT}

gdb:
	${CALC_ENV} gdb ./calc${EXT}

###
#
# rpm rules
#
###

# NOTE: Only the 2 rpm rules should set ${RPM_TOP}!
#
# When making calc RPM, ${RPM_TOP} will be set to the tree
# under which rpm files are built.  You should NOT set RPM_TOP
# by yourself.  Only make rpm and make rpm-preclean should
# set this value.

rpm: clobber rpm-preclean rpm.mk calc.spec.in
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${MAKE} -f rpm.mk all V=${V} RPM_TOP="${RPM_TOP}"
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

rpm-preclean:
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${MAKE} -f rpm.mk $@ V=${V} RPM_TOP="${RPM_TOP}"
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

# rpm static rules
#
rpm-hide-static:
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${RM} -rf static
	${MKDIR} -p static
	${CP} -f -p calc-static${EXT} ${SAMPLE_STATIC_TARGETS} static
	${CP} -f -p libcalc.a custom/libcustcalc.a static
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

rpm-unhide-static:
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${RM} -f calc-static${EXT} ${SAMPLE_STATIC_TARGETS}
	cd static; ${CP} -f -p calc-static${EXT} ${SAMPLE_STATIC_TARGETS} ..
	${RM} -f libcalc.a
	cd static; ${CP} -f -p libcalc.a ..
	${RM} -f custom/libcustcalc.a
	cd static; ${CP} -f -p libcustcalc.a ../custom
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

rpm-chk-static:
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${CALC_ENV} ./calc-static${EXT} -d -q read regress 2>&1 | \
	    ${AWK} -f check.awk
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

rpm-clean-static:
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${RM} -rf static
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

###
#
# Utility rules
#
###

# Form the installed file list
#
inst_files: ${MAKE_FILE} help/Makefile cal/Makefile custom/Makefile \
	    cscript/Makefile ver_calc${EXT}
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${Q} ${RM} -f inst_files
	${Q} echo ${BINDIR}/calc${EXT} > inst_files
	${Q} cd help; LANG=C \
	    ${MAKE} -f Makefile ${HELP_PASSDOWN} echo_inst_files | \
	    ${GREP} '__file__..' | ${SED} -e s'/.*__file__ //' >> ../inst_files
	${Q} cd cal; LANG=C \
	    ${MAKE} -f Makefile ${CAL_PASSDOWN} echo_inst_files | \
	    ${GREP} '__file__..' | ${SED} -e s'/.*__file__ //' >> ../inst_files
	${Q} cd custom; LANG=C \
	    ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} echo_inst_files | \
	    ${GREP} '__file__..' | ${SED} -e s'/.*__file__ //' >> ../inst_files
	${Q} cd cscript; LANG=C \
	    ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} echo_inst_files | \
	    ${GREP} '__file__..' | ${SED} -e s'/.*__file__ //' >> ../inst_files
	${Q} echo ${LIBDIR}/libcalc.a >> inst_files
	${Q} for i in ${LIB_H_SRC} ${BUILD_H_SRC} /dev/null; do \
	    if [ X"$$i" != X"/dev/null" ]; then \
		echo ${CALC_INCDIR}/$$i; \
	    fi; \
	done >> inst_files
	${Q} if [ ! -z "${MANDIR}" ]; then \
	    echo ${MANDIR}/calc.${MANEXT}; \
	fi >> inst_files
	${Q} LANG=C ${SORT} -u inst_files -o inst_files
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

# The olduninstall rule will remove calc files from the older, historic
# locations under the /usr/local directory.  If you are using the
# new default values for ${BINDIR}, ${CALC_SHAREDIR}, ${INCDIR} and ${LIBDIR}
# then you can use this rule to clean out the older calc stuff under
# the /usr/local directory.
#
olduninstall:
	${RM} -f inst_files
	${MAKE} -f Makefile \
		BINDIR=/usr/local/bin \
		INCDIR=/usr/local/include \
		LIBDIR=/usr/local/lib/calc \
		CALC_SHAREDIR=/usr/local/lib/calc \
		HELPDIR=/usr/local/lib/calc/help \
		CALC_INCDIR=/usr/local/include/calc \
		CUSTOMCALDIR=/usr/local/lib/calc/custom \
		CUSTOMHELPDIR=/usr/local/lib/calc/help/custhelp \
		CUSTOMINCDIR=/usr/local/lib/calc/custom \
		SCRIPTDIR=/usr/local/bin/cscript \
		MANDIR=/usr/local/man/man1 \
		inst_files
	${XARGS} ${RM} -f < inst_files
	-${RMDIR} /usr/local/lib/calc/help/custhelp
	-${RMDIR} /usr/local/lib/calc/help
	-${RMDIR} /usr/local/lib/calc/custom
	-${RMDIR} /usr/local/lib/calc
	-${RMDIR} /usr/local/include/calc
	-${RMDIR} /usr/local/bin/cscript
	${RM} -f inst_files

tags: ${CALCSRC} ${LIBSRC} ${H_SRC} ${BUILD_H_SRC} ${MAKE_FILE}
	-${CTAGS} ${CALCSRC} ${LIBSRC} ${H_SRC} ${BUILD_H_SRC} 2>&1 | \
	    ${GREP} -v 'Duplicate entry|Second entry ignored'

clean: custom/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${RM} -f ${LIBOBJS}
	${RM} -f ${CALCOBJS}
	${RM} -f ${UTIL_OBJS}
	${RM} -f ${UTIL_TMP}
	${RM} -f ${UTIL_PROGS}
	${RM} -f ${UTIL_FILES}
	${RM} -f ${SAMPLE_OBJ}
	${RM} -f .libcustcalc_error
	${RM} -f calc.spec.sed
	${Q} echo '=-=-=-=-= Invoking $@ rule for help =-=-=-=-='
	cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} clean
	${Q} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${Q} echo '=-=-=-=-= Invoking $@ rule for cal =-=-=-=-='
	cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} clean
	${Q} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for custom =-=-=-=-='
	cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} clean
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for cscript =-=-=-=-='
	cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} clean
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${Q} echo remove files that are obsolete
	${RM} -rf lib
	${RM} -f endian.h stdarg.h libcalcerr.a cal/obj help/obj
	${RM} -f have_vs.c std_arg.h try_stdarg.c fnvhash.c
	${RM} -f win32dll.h have_malloc.h math_error.h string.h string.c
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

clobber: custom/Makefile clean
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${RM} -f ${SAMPLE_TARGETS}
	${RM} -f ${SAMPLE_STATIC_TARGETS}
	${RM} -f tags .hsrc hsrc
	${RM} -f ${BUILD_H_SRC}
	${RM} -f ${BUILD_C_SRC}
	${RM} -f calc${EXT}
	${RM} -f *_pure_*.[oa]
	${RM} -f *.pure_linkinfo
	${RM} -f *.pure_hardlin
	${RM} -f *.u
	${RM} -f libcalc.a
	${RM} -f libcustcalc.a
	${RM} -f calc.1 calc.usage
	${RM} -f calc.pixie calc.rf calc.Counts calc.cord
	${RM} -rf gen_h skel Makefile.bak tmp.patch
	${RM} -f calc.spec inst_files rpm.mk.patch tmp
	${RM} -f libcalc${LIB_EXT_VERSION}
	${RM} -f libcalc*
	${RM} -f libcustcalc${LIB_EXT_VERSION}
	${RM} -f libcustcalc*
	${RM} -f calc-static${EXT}
	${RM} -f ${CALC_STATIC_LIBS}
	${RM} -f all
	${V} echo '=-=-=-=-= Invoking $@ rule for help =-=-=-=-='
	-cd help; ${RM} -f all; ${MAKE} -f Makefile ${HELP_PASSDOWN} $@
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for cal =-=-=-=-='
	-cd cal; ${RM} -f all; ${MAKE} -f Makefile ${CAL_PASSDOWN} $@
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for custom =-=-=-=-='
	cd custom; ${RM} -f all; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} $@
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for cscript =-=-=-=-='
	cd cscript; ${RM} -f all; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} $@
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo remove files that are obsolete
	${RM} -rf win32 build
	${RM} -f no_implicit.arg
	${RM} -f no_implicit.c no_implicit.o no_implicit${EXT}
#if 0	/* start of skip for non-Gnu makefiles */
	${RM} -f Makefile.simple
	${RM} -f custom/Makefile
	-${MAKE} -f ${MAKE_FILE} custom/Makefile
#endif	/* end of skip for non-Gnu makefiles */
	${RM} -f .static .dynamic calc-dynamic-only calc-static-only
	-${Q} if [ -e .DS_Store ]; then \
	    echo ${RM} -rf .DS_Store; \
	    ${RM} -rf .DS_Store; \
	fi
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

# install everything
#
# NOTE: Keep the uninstall rule in the reverse order of the install rule
#
install: custom/Makefile ${LIB_H_SRC} ${BUILD_H_SRC} calc.1 all
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	-${Q} if [ ! -z "${T}" ]; then \
	    if [ ! -d ${T} ]; then \
		echo ${MKDIR} -p ${T}; \
		${MKDIR} -p ${T}; \
		echo ${CHMOD} 0755 ${T}; \
		${CHMOD} 0755 ${T}; \
	    fi; \
	fi
	-${Q} if [ ! -d ${T}${BINDIR} ]; then \
	    echo ${MKDIR} -p ${T}${BINDIR}; \
	    ${MKDIR} -p ${T}${BINDIR}; \
	    echo ${CHMOD} 0755 ${T}${BINDIR}; \
	    ${CHMOD} 0755 ${T}${BINDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${INCDIR} ]; then \
	    echo ${MKDIR} -p ${T}${INCDIR}; \
	    ${MKDIR} -p ${T}${INCDIR}; \
	    echo ${CHMOD} 0755 ${T}${INCDIR}; \
	    ${CHMOD} 0755 ${T}${INCDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${LIBDIR} ]; then \
	    echo ${MKDIR} -p ${T}${LIBDIR}; \
	    ${MKDIR} -p ${T}${LIBDIR}; \
	    echo ${CHMOD} 0755 ${T}${LIBDIR}; \
	    ${CHMOD} 0755 ${T}${LIBDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${CALC_SHAREDIR} ]; then \
	    ${MKDIR} -p ${T}${CALC_SHAREDIR}; \
	    echo ${MKDIR} -p ${T}${CALC_SHAREDIR}; \
	    echo ${CHMOD} 0755 ${T}${CALC_SHAREDIR}; \
	    ${CHMOD} 0755 ${T}${CALC_SHAREDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${HELPDIR} ]; then \
	    echo ${MKDIR} -p ${T}${HELPDIR}; \
	    ${MKDIR} -p ${T}${HELPDIR}; \
	    echo ${CHMOD} 0755 ${T}${HELPDIR}; \
	    ${CHMOD} 0755 ${T}${HELPDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${CALC_INCDIR} ]; then \
	    echo ${MKDIR} -p ${T}${CALC_INCDIR}; \
	    ${MKDIR} -p ${T}${CALC_INCDIR}; \
	    echo ${CHMOD} 0755 ${T}${CALC_INCDIR}; \
	    ${CHMOD} 0755 ${T}${CALC_INCDIR}; \
	else \
	    ${TRUE}; \
	fi
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
	-${Q} if [ ! -d ${T}${CUSTOMCALDIR} ]; then \
	    echo ${MKDIR} -p ${T}${CUSTOMCALDIR}; \
	    ${MKDIR} -p ${T}${CUSTOMCALDIR}; \
	    echo ${CHMOD} 0755 ${T}${CUSTOMCALDIR}; \
	    ${CHMOD} 0755 ${T}${CUSTOMCALDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${CUSTOMHELPDIR} ]; then \
	    echo ${MKDIR} -p ${T}${CUSTOMHELPDIR}; \
	    ${MKDIR} -p ${T}${CUSTOMHELPDIR}; \
	    echo ${CHMOD} 0755 ${T}${CUSTOMHELPDIR}; \
	    ${CHMOD} 0755 ${T}${CUSTOMHELPDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -d ${T}${CUSTOMINCDIR} ]; then \
	    echo ${MKDIR} -p ${T}${CUSTOMINCDIR}; \
	    ${MKDIR} -p ${T}${CUSTOMINCDIR}; \
	    echo ${CHMOD} 0755 ${T}${CUSTOMINCDIR}; \
	    ${CHMOD} 0755 ${T}${CUSTOMINCDIR}; \
	else \
	    ${TRUE}; \
	fi
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */
	-${Q} if [ ! -d ${T}${SCRIPTDIR} ]; then \
	    echo ${MKDIR} -p ${T}${SCRIPTDIR}; \
	    ${MKDIR} -p ${T}${SCRIPTDIR}; \
	    echo ${CHMOD} 0755 ${T}${SCRIPTDIR}; \
	    ${CHMOD} 0755 ${T}${SCRIPTDIR}; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -z "${MANDIR}" ]; then \
	    if [ ! -d ${T}${MANDIR} ]; then \
		echo ${MKDIR} -p ${T}${MANDIR}; \
		${MKDIR} -p ${T}${MANDIR}; \
		echo ${CHMOD} 0755 ${T}${MANDIR}; \
		${CHMOD} 0755 ${T}${MANDIR}; \
	    else \
		${TRUE}; \
	    fi; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if [ ! -z "${CATDIR}" ]; then \
	    if [ ! -d ${T}${CATDIR} ]; then \
		echo ${MKDIR} -p ${T}${CATDIR}; \
		${MKDIR} -p ${T}${CATDIR}; \
		echo ${CHMOD} 0755 ${T}${CATDIR}; \
		${CHMOD} 0755 ${T}${CATDIR}; \
	    else \
		${TRUE}; \
	    fi; \
	else \
	    ${TRUE}; \
	fi
	-${Q} if ${CMP} -s calc${EXT} ${T}${BINDIR}/calc${EXT}; then \
	    ${TRUE}; \
	else \
	    ${RM} -f ${T}${BINDIR}/calc.new${EXT}; \
	    ${CP} -f calc${EXT} ${T}${BINDIR}/calc.new${EXT}; \
	    ${CHMOD} 0755 ${T}${BINDIR}/calc.new${EXT}; \
	    ${MV} -f ${T}${BINDIR}/calc.new${EXT} ${T}${BINDIR}/calc${EXT}; \
	    echo "installed ${T}${BINDIR}/calc${EXT}"; \
	fi
	-${Q} if [ -f calc-static${EXT} ]; then \
	    if ${CMP} -s calc-static${EXT} \
	    		 ${T}${BINDIR}/calc-static${EXT}; then \
		${TRUE}; \
	    else \
		${RM} -f ${T}${BINDIR}/calc-static.new${EXT}; \
		${CP} -f calc-static${EXT} \
			 ${T}${BINDIR}/calc-static.new${EXT}; \
		${CHMOD} 0755 ${T}${BINDIR}/calc-static.new${EXT}; \
		${MV} -f ${T}${BINDIR}/calc-static.new${EXT} \
			 ${T}${BINDIR}/calc-static${EXT}; \
		echo "installed ${T}${BINDIR}/calc-static${EXT}"; \
	    fi; \
	fi
	${V} echo '=-=-=-=-= Invoking $@ rule for help =-=-=-=-='
	${Q} cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} install
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for cal =-=-=-=-='
	${Q} cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} install
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
#if 0	/* start of skip for non-Gnu makefiles */
ifdef ALLOW_CUSTOM
#endif	/* end of skip for non-Gnu makefiles */
	${V} echo '=-=-=-=-= Invoking $@ rule for custom =-=-=-=-='
	${Q} cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} install
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
#if 0	/* start of skip for non-Gnu makefiles */
endif
#endif	/* end of skip for non-Gnu makefiles */
	${V} echo '=-=-=-=-= Invoking $@ rule for cscript =-=-=-=-='
	${Q} cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} install
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	-${Q} if [ -f libcalc.a ]; then \
		if ${CMP} -s libcalc.a ${T}${LIBDIR}/libcalc.a; then \
		${TRUE}; \
	        else \
		${RM} -f ${T}${LIBDIR}/libcalc.a.new; \
		${CP} -f libcalc.a ${T}${LIBDIR}/libcalc.a.new; \
		${CHMOD} 0644 ${T}${LIBDIR}/libcalc.a.new; \
		${MV} -f ${T}${LIBDIR}/libcalc.a.new ${T}${LIBDIR}/libcalc.a; \
		${RANLIB} ${T}${LIBDIR}/libcalc.a; \
		echo "installed ${T}${LIBDIR}/libcalc.a"; \
	   fi; \
	fi
	${Q}# NOTE: The this makefile installs libcustcalc${LIB_EXT_VERSION}
	${Q}#       because we only want to perform one ${LDCONFIG} for both
	${Q}#       libcalc${LIB_EXT_VERSION} and libcustcalc${LIB_EXT_VERSION}.
	-${Q} if ${CMP} -s libcalc${LIB_EXT_VERSION} \
		     ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION} && \
	   ${CMP} -s custom/libcustcalc${LIB_EXT_VERSION} \
		     ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}; then \
	    ${TRUE}; \
	else \
	    ${RM} -f ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}.new; \
	    ${CP} -f libcalc${LIB_EXT_VERSION} \
	    	     ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}.new; \
	    ${CHMOD} 0644 ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}.new; \
	    ${MV} -f ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}.new \
	    	     ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}; \
	    echo "installed ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}"; \
	    ${LN} -f -s libcalc${LIB_EXT_VERSION} \
	    		${T}${LIBDIR}/libcalc${LIB_EXT}; \
	    echo "installed ${T}${LIBDIR}/libcalc${LIB_EXT}"; \
	    ${RM} -f ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}.new; \
	    ${CP} -f custom/libcustcalc${LIB_EXT_VERSION} \
	    	     ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}.new; \
	    ${CHMOD} 0644 ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}.new; \
	    ${MV} -f ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}.new \
	    	     ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}; \
	    echo "installed ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}"; \
	    ${LN} -f -s libcustcalc${LIB_EXT_VERSION} \
	    		${T}${LIBDIR}/libcustcalc${LIB_EXT}; \
	    echo "installed ${T}${LIBDIR}/libcalc${LIB_EXT}"; \
	    if [ -z "${T}" -o "/" = "${T}" ]; then \
		if [ ! -z "${LDCONFIG}" ]; then \
		    echo "running ${LDCONFIG}"; \
		    ${LDCONFIG} -v; \
		    echo "finished ${LDCONFIG}"; \
		fi; \
	    fi; \
	fi
	-${Q} for i in ${LIB_H_SRC} ${BUILD_H_SRC} /dev/null; do \
	    if [ "$$i" = "/dev/null" ]; then \
		continue; \
	    fi; \
	    ${RM} -f tmp; \
	    ${SED} -e 's/^\(#[ 	]*include[ 	][ 	]*\)"/\1"calc\//' \
	              $$i > tmp; \
	    if ${CMP} -s tmp ${T}${CALC_INCDIR}/$$i; then \
		${TRUE}; \
	    else \
		${RM} -f ${T}${CALC_INCDIR}/$$i.new; \
		${CP} -f tmp ${T}${CALC_INCDIR}/$$i.new; \
		${CHMOD} 0444 ${T}${CALC_INCDIR}/$$i.new; \
		${MV} -f ${T}${CALC_INCDIR}/$$i.new ${T}${CALC_INCDIR}/$$i; \
		echo "installed ${T}${CALC_INCDIR}/$$i"; \
	    fi; \
	    if [ -f "${T}${CALC_INCDIR}/std_arg.h" ]; then \
		${RM} -f ${T}${CALC_INCDIR}/std_arg.h; \
		echo "removed old ${T}${CALC_INCDIR}/std_arg.h"; \
	    fi; \
	    if [ -f "${T}${CALC_INCDIR}/win32dll.h" ]; then \
		${RM} -f ${T}${CALC_INCDIR}/win32dll.h; \
		echo "removed old ${T}${CALC_INCDIR}/win32dll.h"; \
	    fi; \
	    if [ -f "${T}${CALC_INCDIR}/have_malloc.h" ]; then \
		${RM} -f ${T}${CALC_INCDIR}/have_malloc.h; \
		echo "removed old ${T}${CALC_INCDIR}/have_malloc.h"; \
	    fi; \
	    if [ -f "${T}${CALC_INCDIR}/math_error.h" ]; then \
		${RM} -f ${T}${CALC_INCDIR}/math_error.h; \
		echo "removed old ${T}${CALC_INCDIR}/math_error.h"; \
	    fi; \
	    if [ -f "${T}${CALC_INCDIR}/string.h" ]; then \
		${RM} -f ${T}${CALC_INCDIR}/string.h; \
		echo "removed old ${T}${CALC_INCDIR}/string.h"; \
	    fi; \
	done
	-${Q} if [ -z "${MANDIR}" ]; then \
	    ${TRUE}; \
	else \
	    if ${CMP} -s calc.1 ${T}${MANDIR}/calc.${MANEXT}; then \
		${TRUE}; \
	    else \
		${RM} -f ${T}${MANDIR}/calc.${MANEXT}.new; \
		${CP} -f calc.1 ${T}${MANDIR}/calc.${MANEXT}.new; \
		${CHMOD} 0444 ${T}${MANDIR}/calc.${MANEXT}.new; \
		${MV} -f ${T}${MANDIR}/calc.${MANEXT}.new \
		      ${T}${MANDIR}/calc.${MANEXT}; \
		echo "installed ${T}${MANDIR}/calc.${MANEXT}"; \
	    fi; \
	fi
	-${Q} if [ -z "${CATDIR}" ]; then \
	    ${TRUE}; \
	else \
	    if ${CMP} -s calc.1 ${T}${MANDIR}/calc.${MANEXT}; then \
		${TRUE}; \
	    else \
		if [ -z "${NROFF}" ]; then \
		    echo "${MANMAKE} calc.1 ${T}${CATDIR}"; \
		    ${MANMAKE} calc.1 ${T}${CATDIR}; \
		else \
		    ${RM} -f ${T}${CATDIR}/calc.${CATEXT}.new; \
		    ${NROFF} ${NROFF_ARG} calc.1 > \
			     ${T}${CATDIR}/calc.${CATEXT}.new; \
		    ${CHMOD} ${MANMODE} ${T}${MANDIR}/calc.${CATEXT}.new; \
		    ${MV} -f ${T}${CATDIR}/calc.${CATEXT}.new \
			  ${T}${CATDIR}/calc.${CATEXT}; \
		    echo "installed ${T}${CATDIR}/calc.${CATEXT}"; \
		fi; \
	    fi; \
	fi
	${V} # NOTE: misc install cleanup
	${Q} ${RM} -f tmp
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

# Try to remove everything that was installed
#
# NOTE: Keep the uninstall rule in the reverse order of the install rule
#
uninstall: custom/Makefile
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	-${Q} if [ -z "${CATDIR}" ]; then \
	    ${TRUE}; \
	else \
	    if [ -f "${T}${CATDIR}/calc.${CATEXT}" ]; then \
		${RM} -f "${T}${CATDIR}/calc.${CATEXT}"; \
		if [ -f "${T}${CATDIR}/calc.${CATEXT}" ]; then \
		    echo "cannot uninstall ${T}${CATDIR}/calc.${CATEXT}"; \
		else \
		    echo "uninstalled ${T}${CATDIR}/calc.${CATEXT}"; \
		fi; \
	    fi; \
	fi
	-${Q} if [ -z "${MANDIR}" ]; then \
	    ${TRUE}; \
	else \
	    if [ -f "${T}${MANDIR}/calc.${MANEXT}" ]; then \
		${RM} -f "${T}${MANDIR}/calc.${MANEXT}"; \
		if [ -f "${T}${MANDIR}/calc.${MANEXT}" ]; then \
		    echo "cannot uninstall ${T}${MANDIR}/calc.${MANEXT}"; \
		else \
		    echo "uninstalled ${T}${MANDIR}/calc.${MANEXT}"; \
		fi; \
	    fi; \
	fi
	-${Q} for i in ${BUILD_H_SRC} ${LIB_H_SRC} /dev/null; do \
	    if [ "$$i" = "/dev/null" ]; then \
		continue; \
	    fi; \
	    if [ -f "${T}${CALC_INCDIR}/$$i" ]; then \
		${RM} -f "${T}${CALC_INCDIR}/$$i"; \
		if [ -f "${T}${CALC_INCDIR}/$$i" ]; then \
		    echo "cannot uninstall ${T}${CALC_INCDIR}/$$i"; \
		else \
		    echo "uninstalled ${T}${CALC_INCDIR}/$$i"; \
		fi; \
	    fi; \
	done
	-${Q} if [ -f "${T}${LIBDIR}/libcustcalc${LIB_EXT}" ]; then \
	    ${RM} -f "${T}${LIBDIR}/libcustcalc${LIB_EXT}"; \
	    if [ -f "${T}${LIBDIR}/libcustcalc${LIB_EXT}" ]; then \
		echo "cannot uninstall ${T}${LIBDIR}/libcustcalc${LIB_EXT}"; \
	    else \
		echo "uninstalled ${T}${LIBDIR}/libcustcalc${LIB_EXT}"; \
	    fi; \
	fi
	-${Q} if [ -f "${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}" ]; then \
	    ${RM} -f "${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}"; \
	    if [ -f "${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}" ]; then \
		echo \
		"cannot uninstall ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}";\
	    else \
		echo "uninstalled ${T}${LIBDIR}/libcustcalc${LIB_EXT_VERSION}";\
	    fi; \
	fi
	-${Q} if [ -f "${T}${LIBDIR}/libcalc${LIB_EXT}" ]; then \
	    ${RM} -f "${T}${LIBDIR}/libcalc${LIB_EXT}"; \
	    if [ -f "${T}${LIBDIR}/libcalc${LIB_EXT}" ]; then \
		echo "cannot uninstall ${T}${LIBDIR}/libcalc${LIB_EXT}"; \
	    else \
		echo "uninstalled ${T}${LIBDIR}/libcalc${LIB_EXT}"; \
	    fi; \
	fi
	-${Q} if [ -f "${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}" ]; then \
	    ${RM} -f "${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}"; \
	    if [ -f "${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}" ]; then \
		echo -n "cannot uninstall " \
		echo "${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}"; \
	    else \
		echo "uninstalled ${T}${LIBDIR}/libcalc${LIB_EXT_VERSION}"; \
	    fi; \
	fi
	-${Q} if [ -z "${T}" -o "/" = "${T}" ]; then \
	    if [ ! -z "${LDCONFIG}" ]; then \
		echo "running ${LDCONFIG}"; \
		${LDCONFIG} -v; \
		echo "finished ${LDCONFIG}"; \
	    fi; \
	fi
	-${Q} if [ -f "${T}${LIBDIR}/libcalc.a" ]; then \
	    ${RM} -f "${T}${LIBDIR}/libcalc.a"; \
	    if [ -f "${T}${LIBDIR}/libcalc.a" ]; then \
		echo "cannot uninstall ${T}${LIBDIR}/libcalc.a"; \
	    else \
		echo "uninstalled ${T}${LIBDIR}/libcalc.a"; \
	    fi; \
	fi
	${V} echo '=-=-=-=-= Invoking $@ rule for cscript =-=-=-=-='
	${Q} cd cscript; ${MAKE} -f Makefile ${CSCRIPT_PASSDOWN} uninstall
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for custom =-=-=-=-='
	${Q} cd custom; ${MAKE} -f Makefile ${CUSTOM_PASSDOWN} uninstall
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for cal =-=-=-=-='
	${Q} cd cal; ${MAKE} -f Makefile ${CAL_PASSDOWN} uninstall
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	${V} echo '=-=-=-=-= Invoking $@ rule for help =-=-=-=-='
	${Q} cd help; ${MAKE} -f Makefile ${HELP_PASSDOWN} uninstall
	${V} echo '=-=-=-=-= Back to the main Makefile for $@ rule =-=-=-=-='
	-${Q} if [ -f "${T}${BINDIR}/calc-static${EXT}" ]; then \
	    ${RM} -f "${T}${BINDIR}/calc-static${EXT}"; \
	    if [ -f "${T}${BINDIR}/calc-static${EXT}" ]; then \
		echo "cannot uninstall ${T}${BINDIR}/calc-static${EXT}"; \
	    else \
		echo "uninstalled ${T}${BINDIR}/calc-static${EXT}"; \
	    fi; \
	fi
	-${Q} if [ -f "${T}${BINDIR}/calc${EXT}" ]; then \
	    ${RM} -f "${T}${BINDIR}/calc${EXT}"; \
	    if [ -f "${T}${BINDIR}/calc${EXT}" ]; then \
		echo "cannot uninstall ${T}${BINDIR}/calc${EXT}"; \
	    else \
		echo "uninstalled ${T}${BINDIR}/calc${EXT}"; \
	    fi; \
	fi
	-${Q} for i in ${CATDIR} ${MANDIR} ${SCRIPTDIR} \
		    ${CUSTOMINCDIR} ${CUSTOMHELPDIR} ${CUSTOMCALDIR} \
		    ${CALC_INCDIR} ${LIBDIR} ${INCDIR} ${BINDIR}; do \
	    if [ -d "${T}$$i" ]; then \
		${RMDIR} "${T}$$i" 2>/dev/null; \
		echo "cleaned up ${T}$$i"; \
	    fi; \
	done
	-${Q} if [ ! -z "${T}" ]; then \
	    if [ -d "${T}" ]; then \
		${RMDIR} "${T}" 2>/dev/null; \
		echo "cleaned up ${T}"; \
	    fi; \
	 fi
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

# splint - A tool for statically checking C programs
#
splint: #hsrc
	${SPLINT} ${SPLINT_OPTS} -DCALC_SRC -I. \
	    ${CALCSRC} ${LIBSRC} ${BUILD_C_SRC} ${UTIL_C_SRC}

# strip - for reducing the size of the binary files
#
strip:
	${V} echo '=-=-=-=-= ${MAKE_FILE} start of $@ rule =-=-=-=-='
	${Q} for i in ${UTIL_PROGS} ${SAMPLE_TARGETS} ${SAMPLE_STATIC_TARGETS} \
		 calc${EXT} calc-static${EXT} ${CALC_DYNAMIC_LIBS} \
		 ${CALC_STATIC_LIBS}; do \
	    if [ -s "$$i" -a -w "$$i" ]; then \
		${STRIP} "$$i"; \
		echo "stripped $$i"; \
	    fi; \
	done
	${V} echo '=-=-=-=-= ${MAKE_FILE} end of $@ rule =-=-=-=-='

# calc-symlink - setup symlinks from standard locations into the ${T} tree
#
calc-symlink:
	${Q}if [ -z "${T}" ]; then \
	    echo "cannot use $@ make rule when T make var is empty" 1>&2; \
	    echo "aborting" 1>&2; \
	    exit 1; \
	fi
	-${Q} for i in	${BINDIR}/calc${EXT} \
			${BINDIR}/calc-static${EXT} \
			${SCRIPTDIR} \
			${LIBDIR}/libcalc${LIB_EXT_VERSION} \
			${LIBDIR}/libcustcalc${LIB_EXT_VERSION} \
			${MANDIR}/calc.${MANEXT} \
			${CALC_SHAREDIR} \
			${CALC_INCDIR} \
			; do \
	    if [ -e "${T}$$i" ]; then \
		    if [ ! -L "$$i" -a "${T}$$i" -ef "$$i" ]; then \
		    	echo "ERROR: ${T}$$i is the same as $$i" 1>&2; \
		    else \
			if [ -e "$$i" ]; then \
			    echo ${RM} -f "$$i"; \
			    ${RM} -f "$$i"; \
			fi; \
			echo ${LN} -s "${T}$$i" "$$i"; \
			${LN} -s "${T}$$i" "$$i"; \
	    	    fi; \
	    else \
	        echo "Warning: not found: ${T}$$i" 1>&2; \
	    fi; \
	done
	-${Q} if [ -n "${CATDIR}" ]; then \
	    if [ -e "${T}${CATDIR}/calc.${CATEXT}" ]; then \
		if [ ! -L "${CATDIR}/calc.${CATEXT}" -a \
		     "${T}${CATDIR}/calc.${CATEXT}" -ef \
		     "${CATDIR}/calc.${CATEXT}" ]; then \
		    	echo -n "ERROR: ${T}${CATDIR}/calc.${CATEXT}" 2>&1; \
			echo "is the same as ${CATDIR}/calc.${CATEXT}" 1>&2; \
		else \
		    if [ -e "${CATDIR}/calc.${CATEXT}" ]; then \
			echo ${RM} -f "${CATDIR}/calc.${CATEXT}"; \
			${RM} -f "${CATDIR}/calc.${CATEXT}"; \
		    fi; \
		    echo ${LN} -s "${T}${CATDIR}/calc.${CATEXT}" \
		                  "${CATDIR}/calc.${CATEXT}"; \
		    ${LN} -s "${T}${CATDIR}/calc.${CATEXT}" \
		             "${CATDIR}/calc.${CATEXT}"; \
		fi; \
	    fi; \
	fi

# remove any symlinks that may have been created by calc-symlink
#
calc-unsymlink:
	-${Q} for i in	${BINDIR}/calc${EXT} \
			${BINDIR}/calc-static${EXT} \
			${SCRIPTDIR} \
			${LIBDIR}/libcalc${LIB_EXT_VERSION} \
			${LIBDIR}/libcustcalc${LIB_EXT_VERSION} \
			${MANDIR}/calc.${MANEXT} \
			${CALC_SHAREDIR} \
			${CALC_INCDIR} \
			; do \
	    if [ -L "$$i" ]; then \
		echo ${RM} -f "$$i"; \
		${RM} -f "$$i"; \
	    else \
	        echo "Warning: ignoring non-symlink: $$i" 1>&2; \
	    fi; \
	done
	-${Q} if [ -n "${CATDIR}" ]; then \
	    if [ -L "${CATDIR}/calc.${CATEXT}" ]; then \
		echo ${RM} -f "${CATDIR}/calc.${CATEXT}"; \
		${RM} -f "${CATDIR}/calc.${CATEXT}"; \
	    else \
	        echo "Warning: ignoring non-symlink: ${CATDIR}/calc.${CATEXT}" \
		      1>&2; \
	    fi; \
	fi

###
#
# make depend stuff
#
###

# DO NOT DELETE THIS LINE -- make depend depends on it.

addop.o: addop.c
addop.o: alloc.h
addop.o: block.h
addop.o: byteswap.h
addop.o: calc.h
addop.o: calcerr.h
addop.o: cmath.h
addop.o: config.h
addop.o: decl.h
addop.o: endian_calc.h
addop.o: func.h
addop.o: hash.h
addop.o: have_const.h
addop.o: have_memmv.h
addop.o: have_newstr.h
addop.o: have_stdlib.h
addop.o: have_string.h
addop.o: label.h
addop.o: longbits.h
addop.o: nametype.h
addop.o: opcodes.h
addop.o: qmath.h
addop.o: sha1.h
addop.o: str.h
addop.o: symbol.h
addop.o: token.h
addop.o: value.h
addop.o: zmath.h
align32.o: align32.c
align32.o: have_unistd.h
align32.o: longbits.h
assocfunc.o: alloc.h
assocfunc.o: assocfunc.c
assocfunc.o: block.h
assocfunc.o: byteswap.h
assocfunc.o: calcerr.h
assocfunc.o: cmath.h
assocfunc.o: config.h
assocfunc.o: decl.h
assocfunc.o: endian_calc.h
assocfunc.o: hash.h
assocfunc.o: have_const.h
assocfunc.o: have_memmv.h
assocfunc.o: have_newstr.h
assocfunc.o: have_stdlib.h
assocfunc.o: have_string.h
assocfunc.o: longbits.h
assocfunc.o: nametype.h
assocfunc.o: qmath.h
assocfunc.o: sha1.h
assocfunc.o: str.h
assocfunc.o: value.h
assocfunc.o: zmath.h
blkcpy.o: alloc.h
blkcpy.o: blkcpy.c
blkcpy.o: blkcpy.h
blkcpy.o: block.h
blkcpy.o: byteswap.h
blkcpy.o: calc.h
blkcpy.o: calcerr.h
blkcpy.o: cmath.h
blkcpy.o: config.h
blkcpy.o: decl.h
blkcpy.o: endian_calc.h
blkcpy.o: file.h
blkcpy.o: hash.h
blkcpy.o: have_const.h
blkcpy.o: have_fpos.h
blkcpy.o: have_memmv.h
blkcpy.o: have_newstr.h
blkcpy.o: have_stdlib.h
blkcpy.o: have_string.h
blkcpy.o: longbits.h
blkcpy.o: nametype.h
blkcpy.o: qmath.h
blkcpy.o: sha1.h
blkcpy.o: str.h
blkcpy.o: value.h
blkcpy.o: zmath.h
block.o: alloc.h
block.o: block.c
block.o: block.h
block.o: byteswap.h
block.o: calcerr.h
block.o: cmath.h
block.o: config.h
block.o: decl.h
block.o: endian_calc.h
block.o: hash.h
block.o: have_const.h
block.o: have_memmv.h
block.o: have_newstr.h
block.o: have_stdlib.h
block.o: have_string.h
block.o: longbits.h
block.o: nametype.h
block.o: qmath.h
block.o: sha1.h
block.o: str.h
block.o: value.h
block.o: zmath.h
byteswap.o: alloc.h
byteswap.o: byteswap.c
byteswap.o: byteswap.h
byteswap.o: cmath.h
byteswap.o: decl.h
byteswap.o: endian_calc.h
byteswap.o: have_const.h
byteswap.o: have_memmv.h
byteswap.o: have_newstr.h
byteswap.o: have_stdlib.h
byteswap.o: have_string.h
byteswap.o: longbits.h
byteswap.o: qmath.h
byteswap.o: zmath.h
calc.o: alloc.h
calc.o: args.h
calc.o: block.h
calc.o: byteswap.h
calc.o: calc.c
calc.o: calc.h
calc.o: calcerr.h
calc.o: cmath.h
calc.o: conf.h
calc.o: config.h
calc.o: custom.h
calc.o: decl.h
calc.o: endian_calc.h
calc.o: func.h
calc.o: hash.h
calc.o: have_const.h
calc.o: have_memmv.h
calc.o: have_newstr.h
calc.o: have_stdlib.h
calc.o: have_strdup.h
calc.o: have_string.h
calc.o: have_uid_t.h
calc.o: have_unistd.h
calc.o: have_unused.h
calc.o: hist.h
calc.o: label.h
calc.o: lib_calc.h
calc.o: longbits.h
calc.o: nametype.h
calc.o: opcodes.h
calc.o: qmath.h
calc.o: sha1.h
calc.o: str.h
calc.o: symbol.h
calc.o: token.h
calc.o: value.h
calc.o: zmath.h
calcerr.o: calcerr.c
calcerr.o: calcerr.h
calcerr.o: have_const.h
codegen.o: alloc.h
codegen.o: block.h
codegen.o: byteswap.h
codegen.o: calc.h
codegen.o: calcerr.h
codegen.o: cmath.h
codegen.o: codegen.c
codegen.o: conf.h
codegen.o: config.h
codegen.o: decl.h
codegen.o: endian_calc.h
codegen.o: func.h
codegen.o: hash.h
codegen.o: have_const.h
codegen.o: have_memmv.h
codegen.o: have_newstr.h
codegen.o: have_stdlib.h
codegen.o: have_string.h
codegen.o: have_unistd.h
codegen.o: label.h
codegen.o: lib_calc.h
codegen.o: longbits.h
codegen.o: nametype.h
codegen.o: opcodes.h
codegen.o: qmath.h
codegen.o: sha1.h
codegen.o: str.h
codegen.o: symbol.h
codegen.o: token.h
codegen.o: value.h
codegen.o: zmath.h
comfunc.o: alloc.h
comfunc.o: byteswap.h
comfunc.o: cmath.h
comfunc.o: comfunc.c
comfunc.o: config.h
comfunc.o: decl.h
comfunc.o: endian_calc.h
comfunc.o: have_const.h
comfunc.o: have_memmv.h
comfunc.o: have_newstr.h
comfunc.o: have_stdlib.h
comfunc.o: have_string.h
comfunc.o: longbits.h
comfunc.o: nametype.h
comfunc.o: qmath.h
comfunc.o: zmath.h
commath.o: alloc.h
commath.o: byteswap.h
commath.o: cmath.h
commath.o: commath.c
commath.o: decl.h
commath.o: endian_calc.h
commath.o: have_const.h
commath.o: have_memmv.h
commath.o: have_newstr.h
commath.o: have_stdlib.h
commath.o: have_string.h
commath.o: longbits.h
commath.o: qmath.h
commath.o: zmath.h
config.o: alloc.h
config.o: block.h
config.o: byteswap.h
config.o: calc.h
config.o: calcerr.h
config.o: cmath.h
config.o: config.c
config.o: config.h
config.o: custom.h
config.o: decl.h
config.o: endian_calc.h
config.o: hash.h
config.o: have_const.h
config.o: have_memmv.h
config.o: have_newstr.h
config.o: have_stdlib.h
config.o: have_strdup.h
config.o: have_string.h
config.o: have_times.h
config.o: longbits.h
config.o: nametype.h
config.o: qmath.h
config.o: sha1.h
config.o: str.h
config.o: token.h
config.o: value.h
config.o: zmath.h
config.o: zrand.h
const.o: alloc.h
const.o: block.h
const.o: byteswap.h
const.o: calc.h
const.o: calcerr.h
const.o: cmath.h
const.o: config.h
const.o: const.c
const.o: decl.h
const.o: endian_calc.h
const.o: hash.h
const.o: have_const.h
const.o: have_memmv.h
const.o: have_newstr.h
const.o: have_stdlib.h
const.o: have_string.h
const.o: longbits.h
const.o: nametype.h
const.o: qmath.h
const.o: sha1.h
const.o: str.h
const.o: value.h
const.o: zmath.h
custom.o: alloc.h
custom.o: block.h
custom.o: byteswap.h
custom.o: calc.h
custom.o: calcerr.h
custom.o: cmath.h
custom.o: config.h
custom.o: custom.c
custom.o: custom.h
custom.o: decl.h
custom.o: endian_calc.h
custom.o: hash.h
custom.o: have_const.h
custom.o: have_memmv.h
custom.o: have_newstr.h
custom.o: have_stdlib.h
custom.o: have_string.h
custom.o: longbits.h
custom.o: nametype.h
custom.o: qmath.h
custom.o: sha1.h
custom.o: str.h
custom.o: value.h
custom.o: zmath.h
endian.o: endian.c
endian.o: have_stdlib.h
endian.o: have_unistd.h
file.o: alloc.h
file.o: block.h
file.o: byteswap.h
file.o: calc.h
file.o: calcerr.h
file.o: cmath.h
file.o: config.h
file.o: decl.h
file.o: endian_calc.h
file.o: file.c
file.o: file.h
file.o: fposval.h
file.o: hash.h
file.o: have_const.h
file.o: have_fpos.h
file.o: have_fpos_pos.h
file.o: have_memmv.h
file.o: have_newstr.h
file.o: have_stdlib.h
file.o: have_string.h
file.o: have_unistd.h
file.o: longbits.h
file.o: nametype.h
file.o: qmath.h
file.o: sha1.h
file.o: str.h
file.o: value.h
file.o: zmath.h
fposval.o: endian_calc.h
fposval.o: fposval.c
fposval.o: have_fpos.h
fposval.o: have_fpos_pos.h
fposval.o: have_offscl.h
fposval.o: have_posscl.h
func.o: alloc.h
func.o: block.h
func.o: byteswap.h
func.o: calc.h
func.o: calcerr.h
func.o: cmath.h
func.o: config.h
func.o: custom.h
func.o: decl.h
func.o: endian_calc.h
func.o: file.h
func.o: func.c
func.o: func.h
func.o: hash.h
func.o: have_const.h
func.o: have_fpos.h
func.o: have_memmv.h
func.o: have_newstr.h
func.o: have_rusage.h
func.o: have_stdlib.h
func.o: have_strdup.h
func.o: have_string.h
func.o: have_times.h
func.o: have_unistd.h
func.o: have_unused.h
func.o: label.h
func.o: longbits.h
func.o: nametype.h
func.o: opcodes.h
func.o: prime.h
func.o: qmath.h
func.o: sha1.h
func.o: str.h
func.o: symbol.h
func.o: token.h
func.o: value.h
func.o: zmath.h
func.o: zrand.h
func.o: zrandom.h
hash.o: alloc.h
hash.o: block.h
hash.o: byteswap.h
hash.o: calc.h
hash.o: calcerr.h
hash.o: cmath.h
hash.o: config.h
hash.o: decl.h
hash.o: endian_calc.h
hash.o: hash.c
hash.o: hash.h
hash.o: have_const.h
hash.o: have_memmv.h
hash.o: have_newstr.h
hash.o: have_stdlib.h
hash.o: have_string.h
hash.o: longbits.h
hash.o: nametype.h
hash.o: qmath.h
hash.o: sha1.h
hash.o: str.h
hash.o: value.h
hash.o: zmath.h
hash.o: zrand.h
hash.o: zrandom.h
have_const.o: have_const.c
have_fpos.o: have_fpos.c
have_fpos_pos.o: have_fpos.h
have_fpos_pos.o: have_fpos_pos.c
have_fpos_pos.o: have_posscl.h
have_getpgid.o: have_getpgid.c
have_getprid.o: have_getprid.c
have_getsid.o: have_getsid.c
have_gettime.o: have_gettime.c
have_memmv.o: have_memmv.c
have_newstr.o: have_newstr.c
have_offscl.o: have_offscl.c
have_posscl.o: have_fpos.h
have_posscl.o: have_posscl.c
have_rusage.o: have_rusage.c
have_stdvs.o: have_stdlib.h
have_stdvs.o: have_stdvs.c
have_stdvs.o: have_string.h
have_stdvs.o: have_unistd.h
have_strdup.o: have_strdup.c
have_uid_t.o: have_uid_t.c
have_uid_t.o: have_unistd.h
have_unused.o: have_unused.c
have_ustat.o: have_ustat.c
have_varvs.o: have_string.h
have_varvs.o: have_unistd.h
have_varvs.o: have_varvs.c
help.o: alloc.h
help.o: block.h
help.o: byteswap.h
help.o: calc.h
help.o: calcerr.h
help.o: cmath.h
help.o: conf.h
help.o: config.h
help.o: decl.h
help.o: endian_calc.h
help.o: hash.h
help.o: have_const.h
help.o: have_memmv.h
help.o: have_newstr.h
help.o: have_stdlib.h
help.o: have_string.h
help.o: have_unistd.h
help.o: help.c
help.o: longbits.h
help.o: nametype.h
help.o: qmath.h
help.o: sha1.h
help.o: str.h
help.o: value.h
help.o: zmath.h
hist.o: alloc.h
hist.o: block.h
hist.o: byteswap.h
hist.o: calc.h
hist.o: calcerr.h
hist.o: cmath.h
hist.o: config.h
hist.o: decl.h
hist.o: endian_calc.h
hist.o: hash.h
hist.o: have_const.h
hist.o: have_memmv.h
hist.o: have_newstr.h
hist.o: have_stdlib.h
hist.o: have_strdup.h
hist.o: have_string.h
hist.o: have_unistd.h
hist.o: have_unused.h
hist.o: hist.c
hist.o: hist.h
hist.o: longbits.h
hist.o: nametype.h
hist.o: qmath.h
hist.o: sha1.h
hist.o: str.h
hist.o: value.h
hist.o: zmath.h
input.o: alloc.h
input.o: block.h
input.o: byteswap.h
input.o: calc.h
input.o: calcerr.h
input.o: cmath.h
input.o: conf.h
input.o: config.h
input.o: decl.h
input.o: endian_calc.h
input.o: hash.h
input.o: have_const.h
input.o: have_memmv.h
input.o: have_newstr.h
input.o: have_stdlib.h
input.o: have_string.h
input.o: have_unistd.h
input.o: hist.h
input.o: input.c
input.o: longbits.h
input.o: nametype.h
input.o: qmath.h
input.o: sha1.h
input.o: str.h
input.o: value.h
input.o: zmath.h
jump.o: decl.h
jump.o: have_const.h
jump.o: jump.c
jump.o: jump.h
label.o: alloc.h
label.o: block.h
label.o: byteswap.h
label.o: calc.h
label.o: calcerr.h
label.o: cmath.h
label.o: config.h
label.o: decl.h
label.o: endian_calc.h
label.o: func.h
label.o: hash.h
label.o: have_const.h
label.o: have_memmv.h
label.o: have_newstr.h
label.o: have_stdlib.h
label.o: have_string.h
label.o: label.c
label.o: label.h
label.o: longbits.h
label.o: nametype.h
label.o: opcodes.h
label.o: qmath.h
label.o: sha1.h
label.o: str.h
label.o: token.h
label.o: value.h
label.o: zmath.h
lib_calc.o: alloc.h
lib_calc.o: block.h
lib_calc.o: byteswap.h
lib_calc.o: calc.h
lib_calc.o: calcerr.h
lib_calc.o: cmath.h
lib_calc.o: conf.h
lib_calc.o: config.h
lib_calc.o: custom.h
lib_calc.o: decl.h
lib_calc.o: endian_calc.h
lib_calc.o: func.h
lib_calc.o: hash.h
lib_calc.o: have_const.h
lib_calc.o: have_memmv.h
lib_calc.o: have_newstr.h
lib_calc.o: have_stdlib.h
lib_calc.o: have_strdup.h
lib_calc.o: have_string.h
lib_calc.o: have_unistd.h
lib_calc.o: label.h
lib_calc.o: lib_calc.c
lib_calc.o: lib_calc.h
lib_calc.o: longbits.h
lib_calc.o: nametype.h
lib_calc.o: qmath.h
lib_calc.o: sha1.h
lib_calc.o: str.h
lib_calc.o: symbol.h
lib_calc.o: terminal.h
lib_calc.o: token.h
lib_calc.o: value.h
lib_calc.o: zmath.h
lib_calc.o: zrandom.h
lib_util.o: alloc.h
lib_util.o: byteswap.h
lib_util.o: decl.h
lib_util.o: endian_calc.h
lib_util.o: have_const.h
lib_util.o: have_memmv.h
lib_util.o: have_newstr.h
lib_util.o: have_stdlib.h
lib_util.o: have_string.h
lib_util.o: lib_util.c
lib_util.o: lib_util.h
lib_util.o: longbits.h
lib_util.o: zmath.h
listfunc.o: alloc.h
listfunc.o: block.h
listfunc.o: byteswap.h
listfunc.o: calcerr.h
listfunc.o: cmath.h
listfunc.o: config.h
listfunc.o: decl.h
listfunc.o: endian_calc.h
listfunc.o: hash.h
listfunc.o: have_const.h
listfunc.o: have_memmv.h
listfunc.o: have_newstr.h
listfunc.o: have_stdlib.h
listfunc.o: have_string.h
listfunc.o: listfunc.c
listfunc.o: longbits.h
listfunc.o: nametype.h
listfunc.o: qmath.h
listfunc.o: sha1.h
listfunc.o: str.h
listfunc.o: value.h
listfunc.o: zmath.h
listfunc.o: zrand.h
longbits.o: have_stdlib.h
longbits.o: have_unistd.h
longbits.o: longbits.c
matfunc.o: alloc.h
matfunc.o: block.h
matfunc.o: byteswap.h
matfunc.o: calcerr.h
matfunc.o: cmath.h
matfunc.o: config.h
matfunc.o: decl.h
matfunc.o: endian_calc.h
matfunc.o: hash.h
matfunc.o: have_const.h
matfunc.o: have_memmv.h
matfunc.o: have_newstr.h
matfunc.o: have_stdlib.h
matfunc.o: have_string.h
matfunc.o: have_unused.h
matfunc.o: longbits.h
matfunc.o: matfunc.c
matfunc.o: nametype.h
matfunc.o: qmath.h
matfunc.o: sha1.h
matfunc.o: str.h
matfunc.o: value.h
matfunc.o: zmath.h
matfunc.o: zrand.h
math_error.o: alloc.h
math_error.o: args.h
math_error.o: block.h
math_error.o: byteswap.h
math_error.o: calc.h
math_error.o: calcerr.h
math_error.o: cmath.h
math_error.o: config.h
math_error.o: decl.h
math_error.o: endian_calc.h
math_error.o: hash.h
math_error.o: have_const.h
math_error.o: have_memmv.h
math_error.o: have_newstr.h
math_error.o: have_stdlib.h
math_error.o: have_string.h
math_error.o: lib_calc.h
math_error.o: longbits.h
math_error.o: math_error.c
math_error.o: nametype.h
math_error.o: qmath.h
math_error.o: sha1.h
math_error.o: str.h
math_error.o: value.h
math_error.o: zmath.h
obj.o: alloc.h
obj.o: block.h
obj.o: byteswap.h
obj.o: calc.h
obj.o: calcerr.h
obj.o: cmath.h
obj.o: config.h
obj.o: decl.h
obj.o: endian_calc.h
obj.o: func.h
obj.o: hash.h
obj.o: have_const.h
obj.o: have_memmv.h
obj.o: have_newstr.h
obj.o: have_stdlib.h
obj.o: have_string.h
obj.o: label.h
obj.o: longbits.h
obj.o: nametype.h
obj.o: obj.c
obj.o: opcodes.h
obj.o: qmath.h
obj.o: sha1.h
obj.o: str.h
obj.o: symbol.h
obj.o: value.h
obj.o: zmath.h
opcodes.o: alloc.h
opcodes.o: block.h
opcodes.o: byteswap.h
opcodes.o: calc.h
opcodes.o: calcerr.h
opcodes.o: cmath.h
opcodes.o: config.h
opcodes.o: custom.h
opcodes.o: decl.h
opcodes.o: endian_calc.h
opcodes.o: file.h
opcodes.o: func.h
opcodes.o: hash.h
opcodes.o: have_const.h
opcodes.o: have_fpos.h
opcodes.o: have_memmv.h
opcodes.o: have_newstr.h
opcodes.o: have_stdlib.h
opcodes.o: have_string.h
opcodes.o: have_unused.h
opcodes.o: hist.h
opcodes.o: label.h
opcodes.o: lib_calc.h
opcodes.o: longbits.h
opcodes.o: nametype.h
opcodes.o: opcodes.c
opcodes.o: opcodes.h
opcodes.o: qmath.h
opcodes.o: sha1.h
opcodes.o: str.h
opcodes.o: symbol.h
opcodes.o: value.h
opcodes.o: zmath.h
opcodes.o: zrand.h
opcodes.o: zrandom.h
pix.o: alloc.h
pix.o: byteswap.h
pix.o: decl.h
pix.o: endian_calc.h
pix.o: have_const.h
pix.o: have_memmv.h
pix.o: have_newstr.h
pix.o: have_stdlib.h
pix.o: have_string.h
pix.o: longbits.h
pix.o: pix.c
pix.o: prime.h
pix.o: qmath.h
pix.o: zmath.h
poly.o: alloc.h
poly.o: block.h
poly.o: byteswap.h
poly.o: calcerr.h
poly.o: cmath.h
poly.o: config.h
poly.o: decl.h
poly.o: endian_calc.h
poly.o: hash.h
poly.o: have_const.h
poly.o: have_memmv.h
poly.o: have_newstr.h
poly.o: have_stdlib.h
poly.o: have_string.h
poly.o: longbits.h
poly.o: nametype.h
poly.o: poly.c
poly.o: qmath.h
poly.o: sha1.h
poly.o: str.h
poly.o: value.h
poly.o: zmath.h
prime.o: alloc.h
prime.o: byteswap.h
prime.o: decl.h
prime.o: endian_calc.h
prime.o: have_const.h
prime.o: have_memmv.h
prime.o: have_newstr.h
prime.o: have_stdlib.h
prime.o: have_string.h
prime.o: jump.h
prime.o: longbits.h
prime.o: prime.c
prime.o: prime.h
prime.o: qmath.h
prime.o: zmath.h
qfunc.o: alloc.h
qfunc.o: byteswap.h
qfunc.o: config.h
qfunc.o: decl.h
qfunc.o: endian_calc.h
qfunc.o: have_const.h
qfunc.o: have_memmv.h
qfunc.o: have_newstr.h
qfunc.o: have_stdlib.h
qfunc.o: have_string.h
qfunc.o: longbits.h
qfunc.o: nametype.h
qfunc.o: prime.h
qfunc.o: qfunc.c
qfunc.o: qmath.h
qfunc.o: zmath.h
qio.o: alloc.h
qio.o: args.h
qio.o: byteswap.h
qio.o: config.h
qio.o: decl.h
qio.o: endian_calc.h
qio.o: have_const.h
qio.o: have_memmv.h
qio.o: have_newstr.h
qio.o: have_stdlib.h
qio.o: have_string.h
qio.o: have_unused.h
qio.o: longbits.h
qio.o: nametype.h
qio.o: qio.c
qio.o: qmath.h
qio.o: zmath.h
qmath.o: alloc.h
qmath.o: byteswap.h
qmath.o: config.h
qmath.o: decl.h
qmath.o: endian_calc.h
qmath.o: have_const.h
qmath.o: have_memmv.h
qmath.o: have_newstr.h
qmath.o: have_stdlib.h
qmath.o: have_string.h
qmath.o: longbits.h
qmath.o: nametype.h
qmath.o: qmath.c
qmath.o: qmath.h
qmath.o: zmath.h
qmod.o: alloc.h
qmod.o: byteswap.h
qmod.o: config.h
qmod.o: decl.h
qmod.o: endian_calc.h
qmod.o: have_const.h
qmod.o: have_memmv.h
qmod.o: have_newstr.h
qmod.o: have_stdlib.h
qmod.o: have_string.h
qmod.o: longbits.h
qmod.o: nametype.h
qmod.o: qmath.h
qmod.o: qmod.c
qmod.o: zmath.h
qtrans.o: alloc.h
qtrans.o: byteswap.h
qtrans.o: decl.h
qtrans.o: endian_calc.h
qtrans.o: have_const.h
qtrans.o: have_memmv.h
qtrans.o: have_newstr.h
qtrans.o: have_stdlib.h
qtrans.o: have_string.h
qtrans.o: longbits.h
qtrans.o: qmath.h
qtrans.o: qtrans.c
qtrans.o: zmath.h
quickhash.o: alloc.h
quickhash.o: block.h
quickhash.o: byteswap.h
quickhash.o: calcerr.h
quickhash.o: cmath.h
quickhash.o: config.h
quickhash.o: decl.h
quickhash.o: endian_calc.h
quickhash.o: hash.h
quickhash.o: have_const.h
quickhash.o: have_memmv.h
quickhash.o: have_newstr.h
quickhash.o: have_stdlib.h
quickhash.o: have_string.h
quickhash.o: longbits.h
quickhash.o: nametype.h
quickhash.o: qmath.h
quickhash.o: quickhash.c
quickhash.o: sha1.h
quickhash.o: str.h
quickhash.o: value.h
quickhash.o: zmath.h
quickhash.o: zrand.h
quickhash.o: zrandom.h
sample_many.o: alloc.h
sample_many.o: block.h
sample_many.o: byteswap.h
sample_many.o: calc.h
sample_many.o: calcerr.h
sample_many.o: cmath.h
sample_many.o: config.h
sample_many.o: decl.h
sample_many.o: endian_calc.h
sample_many.o: hash.h
sample_many.o: have_const.h
sample_many.o: have_memmv.h
sample_many.o: have_newstr.h
sample_many.o: have_stdlib.h
sample_many.o: have_string.h
sample_many.o: lib_util.h
sample_many.o: longbits.h
sample_many.o: nametype.h
sample_many.o: qmath.h
sample_many.o: sample_many.c
sample_many.o: sha1.h
sample_many.o: str.h
sample_many.o: value.h
sample_many.o: zmath.h
sample_many.o: zrandom.h
sample_rand.o: alloc.h
sample_rand.o: block.h
sample_rand.o: byteswap.h
sample_rand.o: calc.h
sample_rand.o: calcerr.h
sample_rand.o: cmath.h
sample_rand.o: config.h
sample_rand.o: decl.h
sample_rand.o: endian_calc.h
sample_rand.o: hash.h
sample_rand.o: have_const.h
sample_rand.o: have_memmv.h
sample_rand.o: have_newstr.h
sample_rand.o: have_stdlib.h
sample_rand.o: have_string.h
sample_rand.o: lib_util.h
sample_rand.o: longbits.h
sample_rand.o: nametype.h
sample_rand.o: qmath.h
sample_rand.o: sample_rand.c
sample_rand.o: sha1.h
sample_rand.o: str.h
sample_rand.o: value.h
sample_rand.o: zmath.h
sample_rand.o: zrandom.h
seed.o: alloc.h
seed.o: byteswap.h
seed.o: decl.h
seed.o: endian_calc.h
seed.o: have_const.h
seed.o: have_getpgid.h
seed.o: have_getprid.h
seed.o: have_getsid.h
seed.o: have_gettime.h
seed.o: have_memmv.h
seed.o: have_newstr.h
seed.o: have_rusage.h
seed.o: have_stdlib.h
seed.o: have_string.h
seed.o: have_times.h
seed.o: have_uid_t.h
seed.o: have_unistd.h
seed.o: have_urandom.h
seed.o: have_ustat.h
seed.o: longbits.h
seed.o: qmath.h
seed.o: seed.c
seed.o: zmath.h
sha1.o: align32.h
sha1.o: alloc.h
sha1.o: block.h
sha1.o: byteswap.h
sha1.o: calcerr.h
sha1.o: cmath.h
sha1.o: config.h
sha1.o: decl.h
sha1.o: endian_calc.h
sha1.o: hash.h
sha1.o: have_const.h
sha1.o: have_memmv.h
sha1.o: have_newstr.h
sha1.o: have_stdlib.h
sha1.o: have_string.h
sha1.o: longbits.h
sha1.o: nametype.h
sha1.o: qmath.h
sha1.o: sha1.c
sha1.o: sha1.h
sha1.o: str.h
sha1.o: value.h
sha1.o: zmath.h
size.o: alloc.h
size.o: block.h
size.o: byteswap.h
size.o: calcerr.h
size.o: cmath.h
size.o: config.h
size.o: decl.h
size.o: endian_calc.h
size.o: hash.h
size.o: have_const.h
size.o: have_memmv.h
size.o: have_newstr.h
size.o: have_stdlib.h
size.o: have_string.h
size.o: longbits.h
size.o: nametype.h
size.o: qmath.h
size.o: sha1.h
size.o: size.c
size.o: str.h
size.o: value.h
size.o: zmath.h
size.o: zrand.h
size.o: zrandom.h
str.o: alloc.h
str.o: block.h
str.o: byteswap.h
str.o: calc.h
str.o: calcerr.h
str.o: cmath.h
str.o: config.h
str.o: decl.h
str.o: endian_calc.h
str.o: hash.h
str.o: have_const.h
str.o: have_memmv.h
str.o: have_newstr.h
str.o: have_stdlib.h
str.o: have_string.h
str.o: longbits.h
str.o: nametype.h
str.o: qmath.h
str.o: sha1.h
str.o: str.c
str.o: str.h
str.o: value.h
str.o: zmath.h
symbol.o: alloc.h
symbol.o: block.h
symbol.o: byteswap.h
symbol.o: calc.h
symbol.o: calcerr.h
symbol.o: cmath.h
symbol.o: config.h
symbol.o: decl.h
symbol.o: endian_calc.h
symbol.o: func.h
symbol.o: hash.h
symbol.o: have_const.h
symbol.o: have_memmv.h
symbol.o: have_newstr.h
symbol.o: have_stdlib.h
symbol.o: have_string.h
symbol.o: label.h
symbol.o: longbits.h
symbol.o: nametype.h
symbol.o: opcodes.h
symbol.o: qmath.h
symbol.o: sha1.h
symbol.o: str.h
symbol.o: symbol.c
symbol.o: symbol.h
symbol.o: token.h
symbol.o: value.h
symbol.o: zmath.h
token.o: alloc.h
token.o: args.h
token.o: block.h
token.o: byteswap.h
token.o: calc.h
token.o: calcerr.h
token.o: cmath.h
token.o: config.h
token.o: decl.h
token.o: endian_calc.h
token.o: hash.h
token.o: have_const.h
token.o: have_memmv.h
token.o: have_newstr.h
token.o: have_stdlib.h
token.o: have_string.h
token.o: lib_calc.h
token.o: longbits.h
token.o: nametype.h
token.o: qmath.h
token.o: sha1.h
token.o: str.h
token.o: token.c
token.o: token.h
token.o: value.h
token.o: zmath.h
value.o: alloc.h
value.o: block.h
value.o: byteswap.h
value.o: calc.h
value.o: calcerr.h
value.o: cmath.h
value.o: config.h
value.o: decl.h
value.o: endian_calc.h
value.o: file.h
value.o: func.h
value.o: hash.h
value.o: have_const.h
value.o: have_fpos.h
value.o: have_memmv.h
value.o: have_newstr.h
value.o: have_stdlib.h
value.o: have_string.h
value.o: label.h
value.o: longbits.h
value.o: nametype.h
value.o: opcodes.h
value.o: qmath.h
value.o: sha1.h
value.o: str.h
value.o: symbol.h
value.o: value.c
value.o: value.h
value.o: zmath.h
value.o: zrand.h
value.o: zrandom.h
version.o: alloc.h
version.o: block.h
version.o: byteswap.h
version.o: calc.h
version.o: calcerr.h
version.o: cmath.h
version.o: config.h
version.o: decl.h
version.o: endian_calc.h
version.o: hash.h
version.o: have_const.h
version.o: have_memmv.h
version.o: have_newstr.h
version.o: have_stdlib.h
version.o: have_string.h
version.o: have_unused.h
version.o: longbits.h
version.o: nametype.h
version.o: qmath.h
version.o: sha1.h
version.o: str.h
version.o: value.h
version.o: version.c
version.o: zmath.h
zfunc.o: alloc.h
zfunc.o: byteswap.h
zfunc.o: decl.h
zfunc.o: endian_calc.h
zfunc.o: have_const.h
zfunc.o: have_memmv.h
zfunc.o: have_newstr.h
zfunc.o: have_stdlib.h
zfunc.o: have_string.h
zfunc.o: longbits.h
zfunc.o: zfunc.c
zfunc.o: zmath.h
zio.o: alloc.h
zio.o: args.h
zio.o: byteswap.h
zio.o: config.h
zio.o: decl.h
zio.o: endian_calc.h
zio.o: have_const.h
zio.o: have_memmv.h
zio.o: have_newstr.h
zio.o: have_stdlib.h
zio.o: have_string.h
zio.o: longbits.h
zio.o: nametype.h
zio.o: qmath.h
zio.o: zio.c
zio.o: zmath.h
zmath.o: alloc.h
zmath.o: byteswap.h
zmath.o: decl.h
zmath.o: endian_calc.h
zmath.o: have_const.h
zmath.o: have_memmv.h
zmath.o: have_newstr.h
zmath.o: have_stdlib.h
zmath.o: have_string.h
zmath.o: longbits.h
zmath.o: zmath.c
zmath.o: zmath.h
zmod.o: alloc.h
zmod.o: byteswap.h
zmod.o: config.h
zmod.o: decl.h
zmod.o: endian_calc.h
zmod.o: have_const.h
zmod.o: have_memmv.h
zmod.o: have_newstr.h
zmod.o: have_stdlib.h
zmod.o: have_string.h
zmod.o: longbits.h
zmod.o: nametype.h
zmod.o: qmath.h
zmod.o: zmath.h
zmod.o: zmod.c
zmul.o: alloc.h
zmul.o: byteswap.h
zmul.o: config.h
zmul.o: decl.h
zmul.o: endian_calc.h
zmul.o: have_const.h
zmul.o: have_memmv.h
zmul.o: have_newstr.h
zmul.o: have_stdlib.h
zmul.o: have_string.h
zmul.o: longbits.h
zmul.o: nametype.h
zmul.o: qmath.h
zmul.o: zmath.h
zmul.o: zmul.c
zprime.o: alloc.h
zprime.o: block.h
zprime.o: byteswap.h
zprime.o: calcerr.h
zprime.o: cmath.h
zprime.o: config.h
zprime.o: decl.h
zprime.o: endian_calc.h
zprime.o: hash.h
zprime.o: have_const.h
zprime.o: have_memmv.h
zprime.o: have_newstr.h
zprime.o: have_stdlib.h
zprime.o: have_string.h
zprime.o: jump.h
zprime.o: longbits.h
zprime.o: nametype.h
zprime.o: prime.h
zprime.o: qmath.h
zprime.o: sha1.h
zprime.o: str.h
zprime.o: value.h
zprime.o: zmath.h
zprime.o: zprime.c
zprime.o: zrand.h
zrand.o: alloc.h
zrand.o: block.h
zrand.o: byteswap.h
zrand.o: calcerr.h
zrand.o: cmath.h
zrand.o: config.h
zrand.o: decl.h
zrand.o: endian_calc.h
zrand.o: hash.h
zrand.o: have_const.h
zrand.o: have_memmv.h
zrand.o: have_newstr.h
zrand.o: have_stdlib.h
zrand.o: have_string.h
zrand.o: have_unused.h
zrand.o: longbits.h
zrand.o: nametype.h
zrand.o: qmath.h
zrand.o: sha1.h
zrand.o: str.h
zrand.o: value.h
zrand.o: zmath.h
zrand.o: zrand.c
zrand.o: zrand.h
zrandom.o: alloc.h
zrandom.o: block.h
zrandom.o: byteswap.h
zrandom.o: calcerr.h
zrandom.o: cmath.h
zrandom.o: config.h
zrandom.o: decl.h
zrandom.o: endian_calc.h
zrandom.o: hash.h
zrandom.o: have_const.h
zrandom.o: have_memmv.h
zrandom.o: have_newstr.h
zrandom.o: have_stdlib.h
zrandom.o: have_string.h
zrandom.o: have_unused.h
zrandom.o: longbits.h
zrandom.o: nametype.h
zrandom.o: qmath.h
zrandom.o: sha1.h
zrandom.o: str.h
zrandom.o: value.h
zrandom.o: zmath.h
zrandom.o: zrandom.c
zrandom.o: zrandom.h
