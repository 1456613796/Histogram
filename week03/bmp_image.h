#ifndef OCL_BMP_IMAGE_H
#define OCL_BMP_IMAGE_H
#include <cstdlib>
#include <iostream>
#include <string.h>
#include <stdio.h>

#ifdef WIN32
__pragma( pack(push, 1) )
#else
#pragma pack(push, 1)
#define fopen_s(pFile,filename,mode) ((*(pFile))=fopen((filename),(mode)))==NULL
#endif
    
typedef struct
{
    unsigned char x;
    unsigned char y;
    unsigned char z;
    unsigned char w;
} ColorPalette;

typedef ColorPalette PixelColor;

typedef struct {
    short id;//文件类型
    int size;//位图大小
    short reserved1;//保留，数值为0
    short reserved2;//保留，数值为0
    int offset;//说明头文件到实际数据的偏移量
} BMPHeader ;

typedef struct {
    unsigned int sizeInfo;//这个结构体所需的字节数
    unsigned int width;//图像的宽度
    unsigned int height;//图像的高度
    unsigned short planes;//为目标设备说明颜色平面数，数值总为1
    unsigned short bitsPerPixel;//说明比特数和像素，数值为1(双色)，4(16色)，8(256色)，16(高彩色)，24(真彩色)
    unsigned int compression;//说明数据压缩的类型
    unsigned int imageSize;//图像的大小，以字节为单位
    unsigned int xPelsPerMeter;//水平分辨率
    unsigned int yPelsPerMeter;//竖直分辨率
    unsigned int clrUsed;//说明位图实际使用的彩色表中的颜色索引数
    unsigned int clrImportant;//对位图重要的颜色索引数目，是0的话都重要
}  BMPInfoHeader ;

#ifdef WIN32
__pragma( pack(pop) )
#else
#pragma pack(pop)
#endif
typedef struct {
    const char * filename;
    unsigned int height;
    unsigned int width;
    void        *pixels;
    BMPInfoHeader infoHeader;
    BMPHeader     header;
    void        *storeOffset;
    int         offsetSize;
}Image;



static const short bitMapID = 19778;

void ReadBMPImage(std::string filename,  Image **image);
void ReadBMPGrayscaleImageUchar(std::string filename,  Image **image);
void ReadBMPGrayscaleImageFloat(std::string filename,  Image **image);
void WriteBMPGrayscaleImageFloat(std::string filename,  Image **image, float*imgBuffer);
void ReleaseBMPImage(Image **image);
#endif