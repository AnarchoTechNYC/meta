#!/bin/bash

# Install dependencies and extra utilities.
apt update && \
    apt install --yes xinit openbox xterm keepassxc firefox-esr \
        build-essential libssl-dev libgmp-dev libpcap-dev \
        zlib1g-dev libbz2-dev libkrb5-dev libnss3-dev \
        hashid hashcat

# Build John the Ripper from source because we want the "Jumbo"
# (community) edition, not merely the core JtR in the Debian repo.
mkdir -p src
john_version="1.9.0"
echo "Downloading John the Ripper ${john_version} Jumbo Edition ..."
wget --quiet -O src/john-${john_version}-jumbo-1.tar.xz \
    https://www.openwall.com/john/k/john-${john_version}-jumbo-1.tar.xz
tar -C src -xJvf src/john-${john_version}-jumbo-1.tar.xz
cd src/john-${john_version}-jumbo-1/src
./configure && make && make install
cd -

# Add John run directory to path and Bash completion script.
cat << EOF > ~vagrant/.bash_profile
export PATH=\$PATH:\$HOME/src/john-${john_version}-jumbo-1/run
source \$HOME/src/john-${john_version}-jumbo-1/run/john.bash_completion
EOF

# Symlink lab files.
for i in $(ls /vagrant/*.txt); do
    ln -s "$i" ~vagrant/src/john-${john_version}-jumbo-1/run/"$(basename $i)"
done

# Fixup permissions.
chown -R vagrant:vagrant ~vagrant
