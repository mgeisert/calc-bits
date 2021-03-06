/*
 * DO NOT EDIT -- generated by the Makefile
 */


#if !defined(__FPOSVAL_H__)
#define __FPOSVAL_H__


/* what are our file position & size types? */
#undef FILEPOS_BITS
#define FILEPOS_BITS 64
#undef FILEPOS_LEN
#define FILEPOS_LEN 8
#define SWAP_HALF_IN_FILEPOS(dest, src)		(*(dest) = *(src))

#undef OFF_T_BITS
#define OFF_T_BITS 32
#undef OFF_T_LEN
#define OFF_T_LEN 4
#define SWAP_HALF_IN_OFF_T(dest, src)		(*(dest) = *(src))

#undef DEV_BITS
#define DEV_BITS 32
#undef DEV_LEN
#define DEV_LEN 4
#define SWAP_HALF_IN_DEV(dest, src)	memcpy((void *)(dest), (void *)(src), 4)

#undef INODE_BITS
#define INODE_BITS 16
#undef INODE_LEN
#define INODE_LEN 2
#define SWAP_HALF_IN_INODE(dest, src)	memcpy((void *)(dest), (void *)(src), 2)


#endif /* !__FPOSVAL_H__ */
