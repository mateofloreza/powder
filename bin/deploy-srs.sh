set -ex
COMMIT_HASH=$1
BINDIR=`dirname $0`
source $BINDIR/common.sh

if [ -f $SRCDIR/srs-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

while ! wget -qO - http://repos.emulab.net/emulab.key | sudo apt-key add -
do
    echo Failed to get emulab key, retrying
done

while ! sudo add-apt-repository -y http://repos.emulab.net/powder/ubuntu/
do
    echo Failed to get johnsond ppa, retrying
done

while ! sudo apt-get update
do
    echo Failed to update, retrying
done

sudo apt install -y build-essential \
    cmake \
    iperf3 \
    i7z \
    libfftw3-dev \
    libmbedtls-dev \
    libboost-program-options-dev \
    libconfig++-dev \
    libsctp-dev \
    libuhd-dev \
    libzmq3-dev \
    linux-tools-`uname -r` \
    numactl \
    uhd-host

cd $SRCDIR
git clone $SRS_REPO srsran
cd srsran
git checkout $COMMIT_HASH
mkdir build
cd build
cmake ../
make -j `nproc`
sudo make install
sudo ldconfig
sudo srsran_install_configs.sh service
sudo cp /local/repository/etc/srsran/* /etc/srsran/
sudo apt install -y make g++ libsctp-dev lksctp-tools cmake snap
sudo apt-get install build-essential libssl-dev -y
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0.tar.gz
tar -zxvf cmake-3.20.0.tar.gz
cd cmake-3.20.0
./bootstrap
make
sudo make install
cd
git clone https://github.com/aligungr/UERANSIM
cd UERANSIM/
make



touch $SRCDIR/srs-setup-complete

