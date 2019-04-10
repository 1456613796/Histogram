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
    short id;//�ļ�����
    int size;//λͼ��С
    short reserved1;//��������ֵΪ0
    short reserved2;//��������ֵΪ0
    int offset;//˵��ͷ�ļ���ʵ�����ݵ�ƫ����
} BMPHeader ;

typedef struct {
    unsigned int sizeInfo;//����ṹ��������ֽ���
    unsigned int width;//ͼ��Ŀ��
    unsigned int height;//ͼ��ĸ߶�
    unsigned short planes;//ΪĿ���豸˵����ɫƽ��������ֵ��Ϊ1
    unsigned short bitsPerPixel;//˵�������������أ���ֵΪ1(˫ɫ)��4(16ɫ)��8(256ɫ)��16(�߲�ɫ)��24(���ɫ)
    unsigned int compression;//˵������ѹ��������
    unsigned int imageSize;//ͼ��Ĵ�С�����ֽ�Ϊ��λ
    unsigned int xPelsPerMeter;//ˮƽ�ֱ���
    unsigned int yPelsPerMeter;//��ֱ�ֱ���
    unsigned int clrUsed;//˵��λͼʵ��ʹ�õĲ�ɫ���е���ɫ������
    unsigned int clrImportant;//��λͼ��Ҫ����ɫ������Ŀ����0�Ļ�����Ҫ
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