FROM ubuntu:16.04

LABEL maintainer "Luigy Machaca <luigy.mach.arc@gmail.com>"

#LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"
RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list

ENV CUDA_VERSION 8.0.61
ENV CUDA_PKG_VERSION 8-0=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-8-0=8.0.61.2-1 \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-8.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"



#LABEL maintainer "Luigy Machaca <luigy.mach.arc@gmail.com>"

WORKDIR /root
#Install update and upgrade
RUN apt-get -y update 
RUN apt-get -y upgrade 

#Install wget and curl
RUN apt-get install -y --no-install-recommends wget
RUN apt-get install -y --no-install-recommends curl


#Install cuda-ga2-8.0
#COPY ./cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb /root/
RUN wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb /root/
RUN chmod +x /root/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
RUN dpkg -i /root/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb
RUN apt-key add /var/cuda-repo-8-0-local-ga2/7fa2af80.pub
RUN apt-get update
RUN apt-get install -y --no-install-recommends cuda
RUN rm /root/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb


#ARG repository
#FROM ${repository}:8.0-runtime-ubuntu16.04
#LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-core-$CUDA_PKG_VERSION \
        cuda-misc-headers-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        cuda-nvrtc-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-nvgraph-dev-$CUDA_PKG_VERSION \
        cuda-cusolver-dev-$CUDA_PKG_VERSION \
        cuda-cublas-dev-8-0=8.0.61.2-1 \
        cuda-cufft-dev-$CUDA_PKG_VERSION \
        cuda-curand-dev-$CUDA_PKG_VERSION \
        cuda-cusparse-dev-$CUDA_PKG_VERSION \
        cuda-npp-dev-$CUDA_PKG_VERSION \
        cuda-cudart-dev-$CUDA_PKG_VERSION \
        cuda-driver-dev-$CUDA_PKG_VERSION && \
    rm -rf /var/lib/apt/lists/*
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs:${LIBRARY_PATH}


#ARG repository
#FROM ${repository}:8.0-runtime-ubuntu16.04
#LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDNN_VERSION 7.1.2.21
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda8.0 && \
            rm -rf /var/lib/apt/lists/*

# Install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server
#RUN add-apt-repository ppa:openjdk-r/ppa 
#RUN apt-get install -y apt-utils
#RUN apt-get install -y --no-install-recommends apt-utils 
RUN apt-get install -y --no-install-recommends openjdk-8-jdk #ok
RUN apt-get install -y --no-install-recommends git 
RUN apt-get install -y --no-install-recommends g++ 
RUN apt-get install -y --no-install-recommends vim 
RUN apt-get install -y --no-install-recommends net-tools
RUN apt-get install -y --no-install-recommends iputils-ping
RUN apt-get install -y --no-install-recommends python-software-properties
RUN apt-get install -y --no-install-recommends scala
RUN apt-get install -y --no-install-recommends openssh-client
RUN apt-get install -y --no-install-recommends unzip










