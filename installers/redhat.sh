#!/bin/bash
# Installer for Fedora, RHEL and clones (Rocky, AlmaLinux, CentOS Stream, ...)

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

if command -v dnf >/dev/null 2>&1; then PKG="dnf"; else PKG="yum"; fi

function update_system_packages() {
    install_log "Refreshing package metadata"
    $SUDO $PKG -yq makecache || install_error "Couldn't update package metadata"
}

# Installs the newest available OpenJDK headless runtime from JAVA_CANDIDATES
function install_java() {
    if command -v java > /dev/null 2>&1; then
        check_java_version
        return
    fi

    local v
    for v in $JAVA_CANDIDATES; do
        if $SUDO $PKG -yq install "java-${v}-openjdk-headless" >/dev/null 2>&1; then
            install_log "Installed Java (OpenJDK ${v})"
            return
        fi
    done
    install_error "No OpenJDK package (${JAVA_CANDIDATES}) found. Install Java manually and re-run."
}

function install_dependencies() {
    install_log "Installing required packages"
    $SUDO $PKG -yq install jq rsync wget zip cronie procps-ng util-linux diffutils findutils \
        || install_error "Couldn't install dependencies"

    # screen is not in the base repositories of RHEL 10 and clones; it is in EPEL
    if ! command -v screen >/dev/null 2>&1; then
        if ! $SUDO $PKG -yq install screen >/dev/null 2>&1; then
            install_log "screen not found, enabling EPEL"
            $SUDO $PKG -yq install epel-release || install_error "Couldn't enable EPEL (needed for screen)"
            $SUDO $PKG -yq install screen || install_error "Couldn't install screen"
        fi
    fi
    install_java
}

function enable_init_sysv() {
    install_log "Enabling automatic startup and shutdown (SysV)"
    if command -v chkconfig >/dev/null 2>&1; then
        $SUDO chkconfig --add msm
    fi
}

install_msm
