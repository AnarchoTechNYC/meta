# Some upstream Vagrant boxes don't set the `vagrant` user's password
# correctly, so make sure that's done first.
echo "vagrant:vagrant" | chpasswd

# Intall software tools for practice lab.
export DEBIAN_FRONTEND=noninteractive
echo "wireshark wireshark-common/install-setuid boolean true" | debconf-set-selections
apt-get update && apt-get --yes install dnsutils whois hping3 \
    nmap ndiff ncrack \
    tcpdump tshark wireshark \
    xorg openbox nitrogen zenmap
usermod -a -G wireshark vagrant
echo "PATH=\$PATH:/usr/sbin" >> ~vagrant/.profile

# Set up a GUI for those who want it.
mkdir -p ~vagrant/.config/openbox ~vagrant/.config/nitrogen
echo "nitrogen --restore &" > ~vagrant/.config/openbox/autostart
cat <<END > ~vagrant/.config/nitrogen/nitrogen.cfg
[nitrogen]
view=icon
recurse=true
sort=alpha
icon_caps=false
dirs=/vagrant;
END
cat <<END > ~vagrant/.config/nitrogen/bg-saved.cfg
[xin_-1]
file=/vagrant/provision/space-background.jpg
mode=5
bgcolor=#000000
END
chown -R vagrant:vagrant ~vagrant/
