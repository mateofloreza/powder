set -ex
BINDIR=`dirname $0`
source $BINDIR/common.sh

if [ -f $SRCDIR/open5gs-setup-complete ]; then
    echo "setup already ran; not running again"
    exit 0
fi

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:open5gs/latest
sudo add-apt-repository -y ppa:wireshark-dev/stable
echo "wireshark-common wireshark-common/install-setuid boolean false" | sudo debconf-set-selections
sudo apt update
sudo apt install -y iperf3 open5gs tshark wireshark
sudo cp /local/repository/etc/open5gs/* /etc/open5gs/

sudo systemctl restart open5gs-mmed
sudo systemctl restart open5gs-sgwcd
sudo systemctl restart open5gs-smfd
sudo systemctl restart open5gs-amfd
sudo systemctl restart open5gs-sgwud
sudo systemctl restart open5gs-upfd
sudo systemctl restart open5gs-hssd
sudo systemctl restart open5gs-pcrfd
sudo systemctl restart open5gs-nrfd
sudo systemctl restart open5gs-ausfd
sudo systemctl restart open5gs-udmd
sudo systemctl restart open5gs-pcfd
sudo systemctl restart open5gs-nssfd
sudo systemctl restart open5gs-bsfd
sudo systemctl restart open5gs-udrd

#TODO: find a better method for adding subscriber info
cd $SRCDIR
wget https://raw.githubusercontent.com/open5gs/open5gs/main/misc/db/open5gs-dbctl
chmod +x open5gs-dbctl

# add default ue subscriber so user doesn't have to log into web ui
./open5gs-dbctl add_ue_with_apn 999990000000000 00000000000000000000000000000000 0ed47545168eafe2c39c075829a7b611 internet 
./open5gs-dbctl add_ue_with_apn 999990000000001 11111111111111111111111111111111 0ed47545168eafe2c39c075829a7b611 internet 
./open5gs-dbctl add_ue_with_apn 999990000000002 22222222222222222222222222222222 0ed47545168eafe2c39c075829a7b611 internet 
./open5gs-dbctl add_ue_with_apn 999990000000003 33333333333333333333333333333333 0ed47545168eafe2c39c075829a7b611 ims 
./open5gs-dbctl add_ue_with_apn 999990000000004 44444444444444444444444444444444 0ed47545168eafe2c39c075829a7b611 ims
./open5gs-dbctl type 999990000000000 1
./open5gs-dbctl type 999990000000001 1
./open5gs-dbctl type 999990000000002 1
./open5gs-dbctl type 999990000000003 1
./open5gs-dbctl type 999990000000004 1
touch $SRCDIR/open5gs-setup-complete
