#!/bin/bash

apt-get update && apt-get install --yes nftables \
    lightdm xfce4 xfce4-terminal firefox gufw

# PolicyKit looks in the `sudo` group for privileged users,
# so add `vagrant` user to that group so we can run `gufw`.
usermod -a -G sudo vagrant

# LightDM expects GNOME, not Xfce, by default. Override.
cat <<EOF > /etc/lightdm/lightdm.conf.d/50-xfce-vagrant.conf
[Seat:*]
user-session=xfce
autologin-user=vagrant
autologin-user-timeout=0
EOF
systemctl start lightdm.service
