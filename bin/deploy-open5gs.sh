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
opc="0ed47545168eafe2c39c075829a7b611"
upper=$(($5 - 1))
for i in $(seq 0 $upper); do
    newkey=$(printf "%0.s$i" {1..32}) # example: 33333333333333333333333333333333
    if [ $i -lt 2 ]
    then
        ./open5gs-dbctl add_ue_with_apn 99999000000000$i $newkey $opc internet
        ./open5gs-dbctl type 99999000000000$i 1
    else
        ./open5gs-dbctl add_ue_with_apn 99999000000000$i $newkey $opc ims
        ./open5gs-dbctl type 99999000000000$i 1

done

#./open5gs-dbctl add_ue_with_apn 999990000000000 00112233445566778899aabbccddeeff 0ed47545168eafe2c39c075829a7b61f internet  # IMSI,K,OPC
#./open5gs-dbctl type 999990000000000 1  # APN type IPV4
#./open5gs-dbctl add_ue_with_apn 999990000000001 00112233445566778899aabbccddeef1 0ed47545168eafe2c39c075829a7b611 internet  # IMSI,K,OPC
#./open5gs-dbctl type 999990000000001 1  # APN type IPV4
#./open5gs-dbctl add_ue_with_apn 999990000000002 00112233445566778899aabbccddeef2 0ed47545168eafe2c39c075829a7b612 ims  # IMSI,K,OPC
#./open5gs-dbctl type 999990000000002 1  # APN type IPV4
#./open5gs-dbctl add_ue_with_apn 999990000000003 00112233445566778899aabbccddeef3 0ed47545168eafe2c39c075829a7b613 srsapn  # IMSI,K,OPC
#./open5gs-dbctl type 999990000000003 1  # APN type IPV4
touch $SRCDIR/open5gs-setup-complete
