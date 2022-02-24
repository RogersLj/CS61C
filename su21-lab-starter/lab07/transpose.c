#include "transpose.h"

/* The naive transpose function as a reference. */
void transpose_naive(int n, int blocksize, int *dst, int *src) {
    for (int x = 0; x < n; x++) {
        for (int y = 0; y < n; y++) {
            dst[y + x * n] = src[x + y * n];
        }
    }
}

/* Implement cache blocking below. You should NOT assume that n is a
 * multiple of the block size. */
void transpose_blocking(int n, int blocksize, int *dst, int *src) {
    // YOUR CODE HERE
    for (int xLow = 0; xLow < n; xLow += blocksize) 
    {
        for (int yLow = 0; yLow < n; yLow += blocksize)
        {
            for (int x = xLow; x < xLow + blocksize; ++x)
               for (int y = yLow; y < yLow + blocksize; ++y)
               {
                    dst[y + x * n] = src[x + y * n];
               }
        }

    }
}
