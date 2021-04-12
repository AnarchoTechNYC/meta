#!/bin/bash

declare -A prometheus_tool_versions=(
    ['prometheus']='2.26.0'
    ['alertmanager']='0.21.0'
    ['node_exporter']='1.1.2'
)

download_tarball () {
    local tool="$1"
    local version="$2"
    local url="https://github.com/prometheus/${tool}/releases/download/v${version}/${tool}-${version}.linux-amd64.tar.gz"

    if [ ! -f "$(basename "$url")" ]; then
        echo -n "Downloading $tool version $version ..."
        curl -sLO "$url"
        echo " done"
    fi
}

install_tool () {
    local tool="$1"
    local version="$2"

    mkdir -p /etc/prometheus
    mkdir -p /var/local/lib/prometheus/alertmanager
    chown -R prometheus:nogroup /var/local/lib/prometheus

    echo -n "Installing $tool version $version ..."

    tar -xzf "${tool}-${version}.linux-amd64.tar.gz"

    # Install executables.
    install -o prometheus \
        $(find "$tool-$version.linux-amd64" -type f -executable -print) \
        /usr/local/sbin

    # Install config files, if they exist.
    if [ -f "${tool}-${version}.linux-amd64/${tool}.yml" ]; then
        for file in "$tool-$version.linux-amd64"/*.yml; do
            install -o prometheus -m 644 "$file" /etc/prometheus
        done
    fi

    # Copy contents of subdirectories, if they exist.
    local subdirs="$(ls -d ${tool}-${version}.linux-amd64/*/ 2> /dev/null)"
    [ -n "$subdirs" ] && for dir in $subdirs; do
        install -o prometheus \
            -D "$dir"/* \
	    -t /srv/prometheus/"$(basename "$dir")"
    done

    cp "/vagrant/provision/etc/systemd/system/$tool.service" "/etc/systemd/system/$tool.service"

    echo " done"
}

setup_mailhog () {
    apt-get --yes install golang-go
    go get github.com/mailhog/MailHog
    cat <<EOF > /etc/systemd/system/mailhog.service
[Unit]
Description=MailHog SMTP testing server
Documentation=https://github.com/mailhog/MailHog#readme

[Service]
ExecStart=/root/go/bin/MailHog

[Install]
WantedBy=multi-user.target
EOF
}

main () {
    # Give us a test SMTP server to use.
    setup_mailhog

    # Set up system user for Prometheus binaries to run under.
    adduser --system --home /srv/prometheus --shell /usr/sbin/nologin prometheus

    # Download and install monitoring and observability tools.
    cd "${TMPDIR:-/tmp}"
    for tool in "${!prometheus_tool_versions[@]}"; do
        local v="${prometheus_tool_versions[$tool]}"
        download_tarball "$tool" "$v"
        install_tool "$tool" "$v"
    done
    cd -

    # Enable and start default system services.
    systemctl daemon-reload
    systemctl enable prometheus.service node_exporter.service alertmanager.service mailhog.service
    systemctl start prometheus.service node_exporter.service alertmanager.service mailhog.service

    # Copy example configuration files into place.
    cp /vagrant/provision/etc/prometheus/* /etc/prometheus/
}

main "$@"
