#!/bin/bash
# Installer for Arch Linux and derivatives

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

function update_system_packages() {
    install_log "Upgrading system (Arch does not support partial upgrades)"
    $SUDO pacman --noconfirm -Syu || install_error "Couldn't upgrade the system"
}

# Installs the newest available OpenJDK headless runtime from JAVA_CANDIDATES
function install_java() {
    if command -v java > /dev/null 2>&1; then
        check_java_version
        return
    fi

    local v
    for v in $JAVA_CANDIDATES; do
        if pacman -Si "jre${v}-openjdk-headless" >/dev/null 2>&1; then
            install_log "Installing Java (OpenJDK ${v})"
            $SUDO pacman --noconfirm -S --needed "jre${v}-openjdk-headless" || install_error "Couldn't install Java"
            return
        fi
    done
    install_error "No OpenJDK package (${JAVA_CANDIDATES}) found. Install Java manually and re-run."
}

function install_dependencies() {
    install_log "Installing required packages"
    $SUDO pacman --noconfirm -S --needed jq rsync screen wget zip cronie procps-ng util-linux diffutils findutils \
        || install_error "Couldn't install dependencies"
    install_java
}

install_msm
