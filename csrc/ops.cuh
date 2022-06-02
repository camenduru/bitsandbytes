// Copyright (c) Facebook, Inc. and its affiliates. 
//   
// This source code is licensed under the MIT license found in the 
// LICENSE file in the root directory of this source tree.


#ifndef ops_H
#define ops_H

#include <stdio.h>
#include <iostream>
#include <unistd.h>
#include <assert.h>

#include <cuda_runtime_api.h>
#include <cuda_fp16.h>

#if __CUDA_ARCH__ >= 800
  #include <cuda_bf16.h>
#else
 // no bfloat16 support
#endif

#define CUDA_CHECK_RETURN(value) {                      \
  cudaError_t _m_cudaStat = value;                    \
  if (_m_cudaStat != cudaSuccess) {                   \
    fprintf(stderr, "Error %s at line %d in file %s\n",         \
        cudaGetErrorString(_m_cudaStat), __LINE__, __FILE__);   \
    exit(1);                              \
  } }

#define THREADS_PER_BLOCKS (512)

typedef enum Operations_t
{
	ksmul = 0,
} Operations_t;

typedef enum Optimizer_t
{
	ADAM = 0,
	MOMENTUM = 1,
  RMSPROP = 2,
  LARS = 3,
  ADAGRAD = 4,
} Optimizer_t;

typedef enum Funcs_t
{
	FILL = 0,
	ARANGE = 1,
} Funcs_t;


template <typename T> void estimateQuantiles(T *A, float *code, float offset, int n);
template <typename T, int FUNC> void func(T *A, T *B, T value, long n);

void quantize(float *code, float *A, unsigned char *out, int n);
void dequantize(float *code, unsigned char *A, float *out, int n);
template <typename T, int STOCHASTIC> void quantizeBlockwise(float * code, T *A, float *absmax, unsigned char *out, float* rand, int rand_offset, const int n);
template<typename T> void dequantizeBlockwise(float *code, unsigned char *A, float *absmax, T *out, int block_size, const int n);

template <typename T, int BLOCK_SIZE> void quantizeBlockwiseDynamic(T *A, float *absmax, unsigned char *out, bool is_signed, int n);
template<typename T, int BLOCK_SIZE> void dequantizeBlockwiseDynamic(unsigned char *A, float *absmax, T *out, bool is_signed, int n);

template<typename T, int OPTIMIZER, int BITS> void bnb_optimizer(T* p, T* g,
                void* state1, void* state2, float beta1, float beta2, float eps, int step, float lr, 
                float *code1, float *code2,
                float* absmax1, float* absmax2, float weight_decay, const float gnorm_scale, bool skip_zeros, int n);

template<typename T> void percentileClipping(T * g, float *gnorm_vec, int step, const int n);

void quantize_cpu(float *A, float *absmax, unsigned char *out, int n);
void dequantize_cpu(float *code, unsigned char *A, float *absmax, float *out, int n);

void histogramScatterAdd2D(float* histogram, int *index1, int *index2, float *src, int maxidx1, int n);

#endif







