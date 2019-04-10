#define BIN_SIZE 256                                                                  
#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable                       
__kernel
// ���ÿ���߳���˵��ÿ���̶߳���Ҫ����256�����ص�����

/**
һ��bank�Ŀ��ʱ32bits(��4���ֽ�)��ÿ��bank�Ĵ�Сʱ1KB�����ԣ�ÿ��bank���Դ洢������ʱ256��
�����Ǵ�����Ƶ�ÿ���̴߳����thread�ĸ���
�ϲ����ʵ����������128bytes(�ֽ�)
*/
void histogram_kernel(__global const uint* data,
	__local uchar* sharedArray,
	__global uint* binResultR,
	__global uint* binResultG,
	__global uint* binResultB)
{
	size_t localId = get_local_id(0);//�ֲ����
	size_t globalId = get_global_id(0);//ȫ�ֱ��
	size_t groupId = get_group_id(0);//����
	size_t groupSize = get_local_size(0);//16
	__local uchar* sharedArrayR = sharedArray;
	__local uchar* sharedArrayG = sharedArray + groupSize * BIN_SIZE;
	__local uchar* sharedArrayB = sharedArray + 2 * groupSize * BIN_SIZE;

	/* initialize shared array to zero */
	for (int i = 0; i < BIN_SIZE; ++i)
	{
		sharedArrayR[localId * BIN_SIZE + i] = 0;
		sharedArrayG[localId * BIN_SIZE + i] = 0;
		sharedArrayB[localId * BIN_SIZE + i] = 0;
	}

	barrier(CLK_LOCAL_MEM_FENCE);

	/* calculate thread-histograms */
	// ���߳���Ҫ����256������ֵ
	for (int i = 0; i < BIN_SIZE; ++i)
	{
		uint value = data[globalId * BIN_SIZE + i];//��λ�����̴߳��������ֵ
		uint valueR = value & 0xFF;//����R
		uint valueG = (value & 0xFF00) >> 8;//����G
		uint valueB = (value & 0xFF0000) >> 16;//����B
		sharedArrayR[localId * BIN_SIZE + valueR]++;
		sharedArrayG[localId * BIN_SIZE + valueG]++;
		sharedArrayB[localId * BIN_SIZE + valueB]++;
	}

	barrier(CLK_LOCAL_MEM_FENCE);

	/* merge all thread-histograms into block-histogram */
	// �������߳�ֱ��ͼ�ϲ�Ϊ��ֱ��ͼ
	for (int i = 0; i < BIN_SIZE / groupSize; ++i)
	{
		uint binCountR = 0;
		uint binCountG = 0;
		uint binCountB = 0;
		for (int j = 0; j < groupSize; ++j)
		{
			binCountR += sharedArrayR[j * BIN_SIZE + i * groupSize + localId];
			binCountG += sharedArrayG[j * BIN_SIZE + i * groupSize + localId];
			binCountB += sharedArrayB[j * BIN_SIZE + i * groupSize + localId];
		}

		binResultR[groupId * BIN_SIZE + i * groupSize + localId] = binCountR;
		binResultG[groupId * BIN_SIZE + i * groupSize + localId] = binCountG;
		binResultB[groupId * BIN_SIZE + i * groupSize + localId] = binCountB;
	}
}