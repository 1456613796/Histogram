#define BIN_SIZE 256                                                                  
#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable                       
__kernel
// 针对每个线程来说，每个线程都需要处理256个像素的数据

/**
一个bank的宽度时32bits(即4个字节)，每个bank的大小时1KB，所以，每个bank可以存储的数据时256个
正好是代码设计的每个线程处理的thread的个数
合并访问的最大限制是128bytes(字节)
*/
void histogram_kernel(__global const uint* data,
	__local uchar* sharedArray,
	__global uint* binResultR,
	__global uint* binResultG,
	__global uint* binResultB)
{
	size_t localId = get_local_id(0);//局部编号
	size_t globalId = get_global_id(0);//全局编号
	size_t groupId = get_group_id(0);//组编号
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
	// 本线程需要处理256个像素值
	for (int i = 0; i < BIN_SIZE; ++i)
	{
		uint value = data[globalId * BIN_SIZE + i];//定位到本线程处理的像素值
		uint valueR = value & 0xFF;//处理R
		uint valueG = (value & 0xFF00) >> 8;//处理G
		uint valueB = (value & 0xFF0000) >> 16;//处理B
		sharedArrayR[localId * BIN_SIZE + valueR]++;
		sharedArrayG[localId * BIN_SIZE + valueG]++;
		sharedArrayB[localId * BIN_SIZE + valueB]++;
	}

	barrier(CLK_LOCAL_MEM_FENCE);

	/* merge all thread-histograms into block-histogram */
	// 将所有线程直方图合并为块直方图
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