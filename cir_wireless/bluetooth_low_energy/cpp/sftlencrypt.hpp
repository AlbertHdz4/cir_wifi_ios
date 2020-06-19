//
//  sftlencrypt.hpp
//  DataLoggerConfiguraciones
//
//  Created by softel on 7/31/19.
//  Copyright © 2019 SOFTEL. All rights reserved.
//

#ifndef D_SFTL_ENCRYPT_H
#define D_SFTL_ENCRYPT_H

#include <stdint.h>
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


#endif
