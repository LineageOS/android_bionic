/*	$NetBSD: sha1.h,v 1.13 2005/12/26 18:41:36 perry Exp $	*/

/*
 * SHA-1 in C
 * By Steve Reid <steve@edmweb.com>
 * 100% Public Domain
 */

#ifndef _SYS_SHA1_H_
#define	_SYS_SHA1_H_

#include <sys/cdefs.h>
#include <sys/types.h>

#define SHA1_DIGEST_LENGTH		20
#define SHA1_BLOCK_SIZE 		64

typedef struct {
    uint64_t count;
    uint32_t state[SHA1_DIGEST_LENGTH / 4];
    uint8_t buffer[SHA1_BLOCK_SIZE];
} SHA1_CTX;

__BEGIN_DECLS
void	SHA1Transform(uint32_t[SHA1_DIGEST_LENGTH/4],
	              const uint8_t[SHA1_BLOCK_SIZE]);
void	SHA1Init(SHA1_CTX *);
void	SHA1Update(SHA1_CTX *, const uint8_t *, unsigned int);
void	SHA1Final(uint8_t[SHA1_DIGEST_LENGTH], SHA1_CTX *);
__END_DECLS

#endif /* _SYS_SHA1_H_ */
