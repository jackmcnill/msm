#!/bin/bash
# Installer for Debian, Ubuntu and derivatives

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

export DEBIAN_FRONTEND=noninteractive

function update_system_packages() {
    install_log "Updating package list"
    $SUDO apt-get -yqq update || install_error "Couldn't update package list"
}

# Installs the newest available OpenJDK headless runtime from JAVA_CANDIDATES
function install_java() {
    if command -v java > /dev/null 2>&1; then
        check_java_version
        return
    fi

    local v
    for v in $JAVA_CANDIDATES; do
        if apt-cache show "openjdk-${v}-jre-headless" >/dev/null 2>&1; then
            install_log "Installing Java (OpenJDK ${v})"
            $SUDO apt-get -yqq install "openjdk-${v}-jre-headless" || install_error "Couldn't install Java"
            return
        fi
    done
    install_error "No OpenJDK package (${JAVA_CANDIDATES}) found. Install Java manually and re-run."
}

function install_dependencies() {
    install_log "Installing required packages"
    $SUDO apt-get -yqq install jq rsync screen wget zip cron procps util-linux diffutils findutils \
        || install_error "Couldn't install dependencies"
    install_java
}

function enable_init_sysv() {
    install_log "Enabling automatic startup and shutdown (SysV)"
    if command -v update-rc.d >/dev/null 2>&1; then
        $SUDO update-rc.d msm defaults 99 10
    elif command -v insserv >/dev/null 2>&1; then
        $SUDO insserv msm
    fi
}

install_msm
