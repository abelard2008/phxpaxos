set -e  # exit immediately on error
set -x  # display all commands

git submodule update --init --recursive

(cd third_party && bash ./autoinstall.sh)

./autoinstall.sh
#
make && make install
#
make install
pushd plugin
make && make install
popd

rsync -avz ./include/phxpaxos/*.h ~/.local/include/phxpaxos/
rsync -avz ./plugin/include/phxpaxos_plugin/*.h ~/.local/include/phxpaxos_plugin/
rsync -avz ./lib/libphxpaxos*.a /root/.local/lib64/
