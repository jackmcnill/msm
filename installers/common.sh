# Shared installer logic. Sourced by the distribution specific installers
# (debian.sh, redhat.sh, arch.sh), which overload the functions marked below.
#
# Files (init/msm, msm.conf, cron/msm, ...) are taken from the repository the
# installer is run from. If it is run remotely, they are downloaded from
# MSM_UPDATE_URL. MSM_UPDATE_URL is also written to msm.conf as UPDATE_URL, so
# that "msm update" pulls from your copy of the repository (empty = no updates).

INSTALLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SRC_DIR="$(dirname "$INSTALLER_DIR")"
UPDATE_URL="${MSM_UPDATE_URL:-}"

msm_dir="${MSM_DIR:-/opt/msm}"
msm_user="${MSM_USER:-minecraft}"
msm_user_system=true
dl_dir="$(mktemp -d -t msm-XXXXXX)"
trap 'rm -rf "$dl_dir"' EXIT

# Run privileged commands directly as root, through sudo otherwise
if [[ $EUID -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi

# Java versions to try, newest first. Recent Minecraft releases need a recent
# Java (1.20.5+ needs 21); older ones run fine on the same newer runtime.
JAVA_CANDIDATES="${MSM_JAVA_VERSIONS:-25 21 17}"

# Outputs an MSM INSTALL log line
function install_log() {
    echo -e "\n\033[1;32mMSM INSTALL: $*\033[m"
}

# Outputs an MSM INSTALL ERROR log line and exits with status code 1
function install_error() {
    echo -e "\n\033[1;37;41mMSM INSTALL ERROR: $*\033[m"
    exit 1
}

function has_systemd() {
    [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null 2>&1
}

# $1: path inside the repository, $2: destination file
function fetch_file() {
    if [[ -f "${SRC_DIR}/$1" ]]; then
        cp "${SRC_DIR}/$1" "$2"
    elif [[ -n "$UPDATE_URL" ]]; then
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "${UPDATE_URL}/$1" -o "$2"
        else
            wget -q "${UPDATE_URL}/$1" -O "$2"
        fi
    else
        return 1
    fi
}

### NOTE: all the below functions are overloadable for system-specific installs
### NOTE: some of the below functions MUST be overloaded due to system-specific installs

function config_installation() {
    install_log "Configure installation"

    if [[ -n "$MSM_NONINTERACTIVE" ]]; then
        return
    fi

    echo -n "Install directory [${msm_dir}]: "
    read input
    if [ ! -z "$input" ]; then
        msm_dir="$input"
    fi

    echo -n "Server user to be created [${msm_user}]: "
    read input
    if [ ! -z "$input" ]; then
        msm_user="$input"
    fi

    echo -n "Add new user as system account? [Y/n]: "
    read answer
    if [[ $answer == "n" || $answer == "N" ]]; then
        msm_user_system=false
    fi

    echo -n "Complete installation with these values? [y/N]: "
    read answer
    if [[ $answer != "y" ]]; then
        echo "Installation aborted."
        exit 0
    fi
}

# Verifies that we are root or can use sudo
function check_sudo() {
    if [[ -n "$SUDO" ]] && ! command -v sudo > /dev/null 2>&1; then
        install_error "Run the installer as root, or install sudo first."
    fi
}

# Runs a system package index update
function update_system_packages() {
    # OVERLOAD THIS
    install_error "No function definition for update_system_packages"
}

# Installs dependencies (screen, rsync, zip, wget, jq, cron, Java, ...)
function install_dependencies() {
    # OVERLOAD THIS
    install_error "No function definition for install_dependencies"
}

# Warns if the installed Java is older than 17
function check_java_version() {
    local major
    major="$(java -version 2>&1 | sed -n '1s/.*version "\([0-9]*\)\.\?\([0-9]*\).*/\1 \2/p' | awk '{ if ($1 == 1) print $2; else print $1 }')"
    if [[ -n "$major" && "$major" -lt 17 ]]; then
        install_log "WARNING: Java $major is installed. Current Minecraft versions need Java 17 or newer (1.20.5+ needs 21)."
    fi
}

# Verifies existence of or adds user for Minecraft server (default "minecraft")
function add_minecraft_user() {
    if id "${msm_user}" >/dev/null 2>&1; then
        install_log "User '${msm_user}' already exists"
        return
    fi

    install_log "Creating user '${msm_user}'"
    local opts=(--home-dir "$msm_dir" --shell /bin/bash --user-group)
    if $msm_user_system; then
        opts+=(--system)
    fi
    $SUDO useradd "${opts[@]}" "${msm_user}" || install_error "Couldn't create user '${msm_user}'"
}

# Verifies existence and permissions of msm server directory (default /opt/msm)
function create_msm_directories() {
    install_log "Creating MSM directories"
    if [ ! -d "$msm_dir" ]; then
        $SUDO mkdir -p "$msm_dir" || install_error "Couldn't create directory '$msm_dir'"
    fi
    $SUDO chown -R $msm_user:$msm_user "$msm_dir" || install_error "Couldn't change file ownership for '$msm_dir'"
}

# Collects msm.conf, cron job, init script, systemd units and completion
function download_latest_files() {
    if [ ! -d "$dl_dir" ]; then
        install_error "Temporary directory was not created properly"
    fi

    install_log "Fetching MSM files"
    fetch_file msm.conf "$dl_dir/msm.conf.orig" || install_error "Couldn't get configuration file"
    fetch_file cron/msm "$dl_dir/msm.cron.orig" || install_error "Couldn't get cron file"
    fetch_file init/msm "$dl_dir/msm.init.orig" || install_error "Couldn't get init file"
    fetch_file init/msm.service "$dl_dir/msm.service" || install_error "Couldn't get systemd unit"
    fetch_file init/msm@.service "$dl_dir/msm@.service" || install_error "Couldn't get systemd unit"
    fetch_file bash_completion/msm "$dl_dir/msm.completion" || install_error "Couldn't get completion file"
}

# Patches msm.conf and cron job to use specified username and directory
function patch_latest_files() {
    install_log "Patching MSM configuration file"
    sed 's#USERNAME="minecraft"#USERNAME="'$msm_user'"#g' "$dl_dir/msm.conf.orig" | \
        sed "s#/opt/msm#$msm_dir#g" | \
        sed "s#^UPDATE_URL=.*\$#UPDATE_URL=\"$UPDATE_URL\"#" >"$dl_dir/msm.conf"

    install_log "Patching MSM cron file"
    awk '{ if ($0 !~ /^#/) sub(/minecraft/, "'$msm_user'"); print }' \
        "$dl_dir/msm.cron.orig" | \
        sed "s#/opt/msm#$msm_dir#g" >"$dl_dir/msm.cron"

    cp "$dl_dir/msm.init.orig" "$dl_dir/msm.init"
}

# Installs msm.conf into /etc. An existing configuration is never overwritten.
function install_config() {
    if [ -e /etc/msm.conf ]; then
        install_log "/etc/msm.conf exists, keeping it (new default saved as /etc/msm.conf.new)"
        $SUDO install -m0644 "$dl_dir/msm.conf" /etc/msm.conf.new
        return
    fi
    install_log "Installing MSM configuration file"
    $SUDO install -m0644 "$dl_dir/msm.conf" /etc/msm.conf
    if [ ! -e /etc/msm.conf ]; then
        install_error "Couldn't install configuration file"
    fi
}

# Installs msm.cron into /etc/cron.d. The cron daemon itself is installed by install_dependencies.
function install_cron() {
    install_log "Installing MSM cron file"
    $SUDO install -m0644 "$dl_dir/msm.cron" /etc/cron.d/msm || install_error "Couldn't install cron file"

    if has_systemd; then
        # The service is called "cron" on Debian and "crond" on Red Hat/Arch
        local svc
        for svc in cron crond; do
            if systemctl list-unit-files "${svc}.service" 2>/dev/null | grep -q "^${svc}.service"; then
                $SUDO systemctl enable --now "${svc}.service" >/dev/null 2>&1
                break
            fi
        done
    fi
}

# Installs the script as /usr/local/bin/msm. /etc/init.d/msm stays as a
# symlink for compatibility with old setups and SysV init.
function install_init() {
    install_log "Installing MSM script"
    $SUDO install -D -m0755 "$dl_dir/msm.init" /usr/local/bin/msm || install_error "Couldn't install init file"

    $SUDO mkdir -p /etc/init.d
    $SUDO ln -sf /usr/local/bin/msm /etc/init.d/msm

    install_log "Installing bash completion"
    $SUDO install -D -m0644 "$dl_dir/msm.completion" /etc/bash_completion.d/msm
}

# Enables automatic startup and shutdown
function enable_init() {
    if has_systemd; then
        install_log "Installing systemd service units"
        $SUDO install -m0644 "$dl_dir/msm.service" /etc/systemd/system/msm.service || install_error "Couldn't install systemd unit"
        $SUDO install -m0644 "$dl_dir/msm@.service" /etc/systemd/system/msm@.service
        $SUDO systemctl daemon-reload
        install_log "Enabling automatic startup and shutdown"
        $SUDO systemctl enable msm.service
    else
        enable_init_sysv
    fi
}

# Fallback for systems without systemd
function enable_init_sysv() {
    install_log "No systemd found: please enable /etc/init.d/msm for startup in your init system."
}

# Installs the versioning files. From a checkout they are copied; when run
# remotely with MSM_UPDATE_URL, MSM updates itself from there.
function update_msm() {
    local vdir="${msm_dir}/versioning"
    if [[ -d "${SRC_DIR}/versioning" ]]; then
        install_log "Installing versioning files"
        $SUDO mkdir -p "$vdir"
        $SUDO cp -r "${SRC_DIR}/versioning/." "$vdir/"
        $SUDO chown -R $msm_user:$msm_user "$vdir"
        $SUDO find "$vdir" -type f -name '*.sh' -exec chmod u+x {} +
    elif [[ -n "$UPDATE_URL" ]]; then
        install_log "Asking MSM to update itself"
        $SUDO /usr/local/bin/msm update --noinput
    else
        install_log "WARNING: no versioning files installed (not run from a checkout and MSM_UPDATE_URL is not set)"
    fi
}

function setup_jargroup() {
    install_log "Setup default jar groups"
    $SUDO /usr/local/bin/msm jargroup create minecraft minecraft
}

function install_complete() {
    install_log "Done. Type 'msm help' to get started. Have fun!"
}

function install_msm() {
    config_installation
    check_sudo
    update_system_packages
    install_dependencies
    add_minecraft_user
    create_msm_directories
    download_latest_files
    patch_latest_files
    install_config
    install_cron
    install_init
    enable_init
    update_msm
    setup_jargroup
    install_complete
}
