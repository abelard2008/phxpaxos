#编译准备
1. 为了访问github.com等的顺利，直接在https://www.huaweicloud.com上,

从香港等区域，买一台主机。
2. OS：CentOS Linux release 8.2.2004 (Core)

3. yum install tmux rsync cmake gcc-c++ git openssl-devel re2-devel automake

4. ./build.sh

5. export MY_INSTALL_DIR=$HOME/.local && export PATH="$MY_INSTALL_DIR/bin:$PATH"

6. cd samples/phxkv

7. mkdir cmake/build && cd cmake/build && cmake ../.. && make

 

This repository contains a C++ implementation of the Phxpaxos module.  

See INSTALL for (generic) installation instructions for C++: basically
   sh autoinstall.sh && make  && make install
