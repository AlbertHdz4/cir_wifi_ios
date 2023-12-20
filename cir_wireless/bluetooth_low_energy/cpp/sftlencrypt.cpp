//
//  sftlencrypt.cpp
//  cir_wireless
//
//  Created by softel on 22/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

#include "sftlencrypt.hpp"
#include <limits.h>

// LLAVE : +rJ/HlGVZrvzm*@$

void diversify_key (Enc_Sec_Data_t   *pEncData,
                    u_int8_t  *vDivKey, /* diversified key */
                    u_int8_t  inDataSize ) {
    u_int8_t p;
    u_int8_t a;
    u_int8_t q;
    /* ---------------------------    */
    /* prepare the diversified key    */
    /* ---------------------------    */
    p = 16;
    
    /* spread inKey in vDivKey, in such a way that future interaction with inKey are with distant bytes */
    do {
        --p;
        vDivKey[p^2] = vDivKey[p+16] = pEncData->inKey[p^9];
    } while (p);
    
    a = inDataSize;
    
    /* extra safety: diversification changes with inDataSize */
    p = (q = pEncData->inDivSz) + pEncData->kDivRounds;
    
    /* for each byte in inDiv, then kSFTKeyRounds extra steps */
    do {
        --p;
        vDivKey[p&31] += a ^= (((a>>1)+(q?pEncData->inDiv[--q]:p))^pEncData->inKey[p&15])+vDivKey[(p+17)&31];
    } while (p||q);
    
}


void decryptCpp (Enc_Sec_Data_t    *pEncData,
                 u_int8_t *        ioData,
                 const u_int8_t    inDataSize,
                 u_int8_t *        vDivKey /* [32] */) {
    
    u_int8_t a;
    u_int8_t j;
    u_int8_t p;
    u_int8_t q;
    
    /* ---------------------------    */
    /* decipher the data              */
    /* ---------------------------    */
    j = inDataSize >> 1;
    p = (u_int8_t) (pEncData->kDataRounds*13);
    /* kSFTDtaRounds iterations */
    
    do {
        p += (q = inDataSize)-13;
        /* inDataSize iterations */
        do {
            if (j==0) j = inDataSize;
            if ((a = --q)==0) a = inDataSize;
            a = ioData[a-1];
            ioData[q] ^= (((a>>4)+ioData[--j])^vDivKey[(--p)&31])+a;
        } while (q);
    } while (p);
    
}


void encryptCpp (Enc_Sec_Data_t *pEncData,
                 u_int8_t *     ioData,
                 const u_int8_t inDataSize,
                 u_int8_t *     vDivKey /* [32] */) {
    u_int8_t a;
    u_int8_t j;
    u_int8_t p;
    u_int8_t q;
    
    /* ---------------------------    */
    /* encipher the data              */
    /* ---------------------------    */
    j = inDataSize >> 1;
    a = ioData[inDataSize-1];
    p = 0;
    
    do {
        q = 0;
        do {
            a = ioData[q] ^= (((a>>4)+ioData[j])^vDivKey[p&31])+a;
            if ((++j)==inDataSize) j=0;
            ++p;
        } while(++q!=inDataSize);
        /* inDataSize iterations */
        p -= q;
    } while ((p += 13)!=(u_int8_t)(pEncData->kDataRounds*13));
    /* kSFTDtaRounds iterations */
    
}
