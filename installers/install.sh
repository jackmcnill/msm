#!/bin/bash
#
# MSM installer entry point. Detects the distribution and runs the matching
# installer. Run it as root (or as a user that may use sudo).
#
#   From a checkout/unpacked copy of this repository:   ./installers/install.sh
#   Remote (your own fork):   MSM_UPDATE_URL=https://.../raw/main bash <(curl -L $MSM_UPDATE_URL/installers/install.sh)

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
BASE_URL="${MSM_UPDATE_URL:+${MSM_UPDATE_URL}/installers}"

function check_os() {
    local id="" id_like=""
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        id="$ID"
        id_like="$ID_LIKE"
    fi

    case " $id $id_like " in
        *" debian "*|*" ubuntu "*)
            INSTALL_SCRIPT="debian.sh" ;;
        *" rhel "*|*" fedora "*|*" centos "*|*" rocky "*|*" almalinux "*)
            INSTALL_SCRIPT="redhat.sh" ;;
        *" arch "*|*" archlinux "*)
            INSTALL_SCRIPT="arch.sh" ;;
        *)
            # Fallback for systems without a usable os-release
            if [[ -f /etc/debian_version ]]; then
                INSTALL_SCRIPT="debian.sh"
            elif [[ -f /etc/redhat-release ]]; then
                INSTALL_SCRIPT="redhat.sh"
            elif [[ -f /etc/arch-release ]]; then
                INSTALL_SCRIPT="arch.sh"
            else
                echo "Error, unsupported distribution. Please install manually."
                exit 1
            fi
            ;;
    esac
}

function do_install() {
    if [[ -f "${SELF_DIR}/${INSTALL_SCRIPT}" ]]; then
        exec bash "${SELF_DIR}/${INSTALL_SCRIPT}"
    fi

    if [[ -z "$BASE_URL" ]]; then
        echo "Error, ${INSTALL_SCRIPT} not found next to this script and MSM_UPDATE_URL is not set."
        exit 1
    fi

    local tmp
    tmp="$(mktemp -d -t msm-installer-XXXXXX)" || exit 1
    for f in common.sh "${INSTALL_SCRIPT}"; do
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "${BASE_URL}/${f}" -o "${tmp}/${f}"
        else
            wget -q "${BASE_URL}/${f}" -O "${tmp}/${f}"
        fi || { echo "Error, failed to download ${f}."; rm -rf "$tmp"; exit 1; }
    done
    bash "${tmp}/${INSTALL_SCRIPT}"
    local rc=$?
    rm -rf "$tmp"
    exit $rc
}

check_os
do_install
