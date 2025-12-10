#!/bin/bash
# Test configuration

# Config
PROJ_ROOT=$(dirname $(dirname "${BASH_SOURCE[0]}") )
WP_DEFAULT_SCRIPT_DIR="$HOME/.local/share/wireplumber/scripts/" # TODO: configurable?
WP_CONFIG_DIR="$HOME/.config/wireplumber/wireplumber.conf.d/"
WP_CONFIG_SCRIPT='lib/wireplumber/wireplumber.conf.d/99-my-script.conf'
PROJ_DIST_DIR="${PROJ_ROOT}/dist"
BUILT_SCRIPT_FILENAME='monolith.lua'
#
# Strings
CMD_VALID_TEST_METHODS=('service' 'wpexec')
USAGE="test.sh, takes one command from ${CMD_VALID_TEST_METHODS[@]}\n"


function create_dir() {
    local dirname=$1
    # is dirname empty
    if [[ -z "${dirname}" ]]; then
        return 1
    fi
    # if dir doesn't exist
    if [ ! -e "${dirname}" ]; then
        mkdir -p "${dirname}"
        return $?
    fi
    return 0
}

function setup_dirs() {
    create_dir "${WP_DEFAULT_SCRIPT_DIR}"
    create_dir "${WP_CONFIG_DIR}"
    create_dir "${PROJ_DIST_DIR}"
}

function is_Uservice_running() {
    local servicename=$1
    # returns 0 when running, non-zero otherwise.
    # 3: inactive (dead)
    # 4: not found
    systemctl is-active --quiet --user "${servicename}"
    echo $?
}

function mk_symlink() {
    local real_src=$1
    local linkdir_dst=$2
    local link_dst="${linkdir_dst}/$(basename ${real_src})"
    if [ ! -f "${real_src}" ]; then
        echo "mk_symlink passed real_src that does not exist: ${real_src}"
        return 1
    fi
    if [ -f "${link_dst}" ]; then
        if [ ! -L "${link_dst}" ]; then
            echo "mk_symlink passed linkdir_dst that exists and is not a link: ${link_dst}"
            return 1
        fi
    fi
    if [ -L "${link_dst}" ]; then
        rm -f "${link_dst}";
    fi

    ln -s "${real_src}" "${link_dst}"
    ret=$?

    if [ ! $ret -eq 0 ]; then
        echo "Error: failed to create link '${real_src}' -> '${link_dst}'"
    fi
    return $ret
}

function rm_symlink() {
    local symlink_path=$1
    if [ ! -f "${symlink_path}" ]; then
        echo "Tried to delete non-existent path: '${symlink_path}'"
        return 1
    fi
    if [ ! -L "${symlink_path}" ]; then
        echo "Tried to delete non-symlink path: '${symlink_path}'"
        return 1
    fi
    rm "${symlink_path}"
}

contains() {
    local search="$1"
    shift
    local arr=("$@")
    for item in "${arr[@]}"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

function install() {
    mk_symlink \
        $(realpath "${PROJ_ROOT}/dist/${BUILT_SCRIPT_FILENAME}") \
        "${WP_DEFAULT_SCRIPT_DIR}"
    if [ ! $? -eq 0 ]; then return 1; fi
    mk_symlink \
        $(realpath "${PROJ_ROOT}/${WP_CONFIG_SCRIPT}") \
        "${WP_CONFIG_DIR}"
    if [ ! $? -eq 0 ]; then return 1; fi
}
function uninstall() {
    rm_symlink \
        "${WP_DEFAULT_SCRIPT_DIR}/${BUILT_SCRIPT_FILENAME}"
    if [ ! $? -eq 0 ]; then return 1; fi
    rm_symlink \
        "${WP_CONFIG_DIR}/99-my-script.conf"
    if [ ! $? -eq 0 ]; then return 1; fi
}
function test_service() {
    local wp_up=$(is_Uservice_running wireplumber)
    if [ $wp_up -eq 0 ]; then
        echo 'Error: wireplumber.service is running in user context. Consider stopping it.'
        return 1
    fi
    echo 'Debug: Installing.'
    install && echo 'Success' || echo 'Failure.'
    printf '\n\n'

    # Without tee, script will quit.
    if command -v unbuffer; then
        unbuffer wireplumber 2>&1 | tee
    else
        wireplumber 2>&1 | tee
    fi
    
    printf '\nDebug: Uninstalling.\n'
    uninstall && echo 'Info: Success' || echo 'Error: Failure'
}
function test_wpexec() {
    local wp_up=$(is_Uservice_running wireplumber)
    if [ ! $wp_up -eq 0 ]; then
        echo 'Error: wireplumber.service must be running in user context. Consider starting it.'
        return 1
    fi
    printf 'Info: Starting.\n\n'

    # unbuffer is needed to trick wpexec into coloring stderr when piped.
    ## https://man.archlinux.org/man/unbuffer.1.en
    if command -v unbuffer; then
        unbuffer wpexec "dist/${BUILT_SCRIPT_FILENAME}" 2>&1 | bin/mapper.lua
    else
        echo 'Warn: Missing non-critical command: 'unbuffer' (extra/expect) is needed to pass stderr w/ color.'
        wpexec "dist/${BUILT_SCRIPT_FILENAME}" | bin/mapper.lua
    fi
}

function main() {
    # Exit on error
    set -e
    if [[ $# -eq 0 ]]; then
        printf "${USAGE}"
        exit 1
    fi
    # service // needs better naming, starts wireplumber executable outside systemctl
    # wpexec // starts script using script interpreter
    local test_method=$1
    if ! contains "${test_method}" "${CMD_VALID_TEST_METHODS[@]}"; then
        echo "test_method needs to contain one of '${CMD_VALID_TEST_METHODS[@]}'.";
        return 1
    fi

    # Create directories in wireplumber-recognized directories.
    setup_dirs

    lua "${PROJ_ROOT}/bin/bundle.lua"
    if [ ! $? -eq 0 ]; then
        echo 'Error: lua had an error bundling monolith.';
        exit 1;
    fi
    echo 'Info: lua built the monolith.'

    export WIREPLUMBER_DEBUG='s-custom:T'
    case "${test_method}" in
        'service')
            test_service
            ;;
        'wpexec')
            test_wpexec
            ;;
    esac
    # err checking?
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi

