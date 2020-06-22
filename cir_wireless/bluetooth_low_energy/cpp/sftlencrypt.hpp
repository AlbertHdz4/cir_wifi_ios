//
//  sftlencrypt.hpp
//  cir_wireless
//
//  Created by softel on 22/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

#ifndef sftlencrypt_hpp
#define sftlencrypt_hpp


#include <stdio.h>


struct Mac_Data{
    u_int8_t data[6];       //MAC
    u_int8_t len;           //LONGITUD
};


typedef struct {
    u_int8_t   inKey[16];   //LLAVE
    u_int8_t   inDiv[6];    //MAC
    int16_t    inDivSz;     //TAMAÑO DE MAC
    int16_t    kDivRounds;  //ITERACIONES
    int16_t    kDataRounds; //ITERACIONES
} Enc_Sec_Data_t;

#endif /* sftlencrypt_hpp */
