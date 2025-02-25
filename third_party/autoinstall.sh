#!/bin/bash
export MY_INSTALL_DIR=$HOME/.local
mkdir -p $MY_INSTALL_DIR
export PATH="$MY_INSTALL_DIR/bin:$PATH"
ln -s /usr/bin/aclocal-1.16 /usr/bin/aclocal-1.14
ln -s /usr/bin/automake-1.16 /usr/bin/automake-1.14
current_path=$(pwd);

function perror() {

    echo -e "\033[0;31;1m$1\033[0m"
}

function psucc() {
    echo -e "\e[1;32m$1\e[0m"
}

function go_back()
{
    cd $current_path;
}

function check_dir_exist()
{
    dir_path=$current_path"/$1";
    if [ ! -d $dir_path ]; then
        perror $dir_path" dir not exist.";
        exit 1;
    fi
}

function check_file_exist()
{
    if [ ! -f $1 ]; then
        return 1;
    fi
    return 0;
}

function check_lib_exist()
{
    go_back;
    lib_dir_path="$current_path/$1/lib";
    if [ ! -d $lib_dir_path ]; then
        return 1;
    fi

    lib_file_path=$lib_dir_path"/lib$1.a";
    check_file_exist $lib_file_path;
    ls "$lib_file_path"
    return $?
}

function install_leveldb()
{
    lib_name="leveldb";

    pushd $lib_name;
    make;

    rsync -avz  include/leveldb/ ~/.local/include/leveldb/
    cp out-static/libleveldb.a ~/.local/lib64/
    popd;
    echo "install $lib_name ok."
}

function check_protobuf_installed()
{
    cd $lib_name;
    bin_dir=$(pwd)"/bin";
    include_dir=$(pwd)"/include";

    if [ ! -d $bin_dir ]; then
        return 1;
    fi
    if [ ! -d $include_dir ]; then
        return 1;
    fi
    check_lib_exist $1;
    return $?;
}

function install_protobuf()
{
    lib_name="protobuf";
    check_dir_exist $lib_name;

    # check if aready install.
    check_protobuf_installed $lib_name;
    if [ $? -eq 0 ]; then
        psucc "$lib_name already installed."
        return;
    fi
    # end check.

    go_back;
    cd $lib_name;

    exist_gmock_dir="../gmock";
    if [ -d $exist_gmock_dir ]; then
        if [ ! -d gmock ]; then
            cp -r $exist_gmock_dir gmock;
        fi
    fi

    ./autogen.sh;
    ./configure CXXFLAGS=-fPIC --prefix=$(pwd);
    make && make install;

    check_protobuf_installed $lib_name;
    if [ $? -eq 1 ]; then
        perror "$lib_name install fail. please check compile error info."
        exit 1;
    fi
    psucc "install $lib_name ok."
}

function install_glog()
{
    lib_name="glog";
    pushd $lib_name;
    ./autogen.sh
    if [ -d $exist_gflags_dir ]; then
        # use local gflags
        ./configure CXXFLAGS=-fPIC --prefix=$(pwd) --with-gflags=$exist_gflags_dir;
    else
        # use system gflags
        ./configure CXXFLAGS=-fPIC --prefix=$(pwd);
    fi
    automake --add-missing
    make && make install
    cp ./lib/libglog.a ~/.local/lib/
    rsync -avz include/glog/ ~/.local/include/glog/
    popd 
    echo "install $lib_name ok."
}

function install_grpc()
{
    lib_name="grpc";
    pushd $lib_name;

    mkdir -p cmake/build
    pushd cmake/build
    cmake -DgRPC_INSTALL=ON \
	  -DgRPC_BUILD_TESTS=OFF \
	  -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
	  ../..
    make -j `nproc --all` && make install
    popd
    echo "install $lib_name ok."
}

function install_googletest()
{
    lib_name="googletest";
    pushd $lib_name;

    mkdir -p cmake/build
    pushd cmake/build
    cmake -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
	  ../..
    make -j `nproc --all` && make install
    popd
    popd
    echo "install $lib_name ok."
}

install_grpc;
install_glog;
install_googletest;
install_leveldb;

echo "all done."
