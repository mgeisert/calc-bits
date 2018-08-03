/*
 * DO NOT EDIT -- generated by the Makefile
 */


#if !defined(__LONGBITS_H__)
#define __LONGBITS_H__


#undef LONG_BITS
#define LONG_BITS 32		/* bit length of a long */

/* size of long was forced */

typedef unsigned char USB8;	/* unsigned 8 bits */
typedef signed char SB8;	/* signed 8 bits */

typedef unsigned short USB16;	/* unsigned 16 bits */
typedef short SB16;		/* signed 16 bits */

typedef unsigned long USB32;	/* unsigned 32 bits */
typedef long SB32;		/* signed 32 bits */

#undef HAVE_B64
#define HAVE_B64		/* have USB64 and SB64 types */
typedef unsigned long long USB64;	/* unsigned 64 bits */
typedef long long SB64;		/* signed 64 bits */

/* how to form 64 bit constants */
#define U(x) x ## ULL
#define L(x) x ## LL


#endif /* !__LONGBITS_H__ */
