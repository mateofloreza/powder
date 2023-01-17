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
touch $SRCDIR/cmake_deploy
cd
git clone https://github.com/aligungr/UERANSIM
cd UERANSIM/
make
touch $SRCDIR/ueransim_deploy

cp /local/repository/etc/UERANSIM/open5gs-gnb.yaml ~/UERANSIM/config/open5gs-gnb.yaml
mkdir ~/UERANSIM/config/open5gs-ue
cp /local/repository/etc/UERANSIM/ueran-ue.yaml ~/UERANSIM/config/open5gs-ue/ue-default.yaml
replace_in_file() {
    # $1 is string to find, $2 is string to replace, $3 is filename
    sed -i "s/$1/$2/g" $3
}

cd ~/UERANSIM/config/open5gs-ue
# autogenerate config files for each ue
upper=$((5 - 1))
for i in $(seq 0 $upper); do
    file=ue"$i.yaml"
    defaultkey="00112233445566778899aabbccddeef1"
    newkey=$(printf "%0.s$i" {1..32})
    cp ue-default.yaml $file
    replace_in_file $defaultkey $newkey $file
    defaultimsi="imsi-999990000000001"
    newimsi="imsi-99999000000000$i"
    replace_in_file $defaultimsi $newimsi $file
    defaultapn="internet"
    newapn="ims"
    if [ $i -gt 2 ]
    then
        replace_in_file $defaultapn $newapn $file
    fi
done


touch $SRCDIR/srs-setup-complete

