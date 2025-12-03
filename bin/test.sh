#!/bin/bash
# Test configuration

PROJ_ROOT=$(dirname $(dirname "${BASH_SOURCE[0]}") )
WP_DEFAULT_SCRIPT_DIR="$HOME/.local/share/wireplumber/scripts/" # TODO: configurable?
WP_CONFIG_DIR="$HOME/.config/wireplumber/wireplumber.conf.d/"
PROJ_DIST_DIR="${PROJ_ROOT}/dist"

function create_dir() {
    local dirname=$1
    # is dirname empty
    if [[ -z "${dirname}" ]]; then
        return 1
    fi
    # if dir doesn't exist
    if [ ! -e "${dirname}" ]; then
        # TODO: what if something before $dirname exists and is a file, and a dir cannot be made?
        mkdir -p "${dirname}"
        return $?
    fi
    # if the dir was made
    if [ -d "${dirname}" ]; then
        return 0
    fi

    echo "'${dirname}' exists and is not a directory! Cannot proceed."
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



function main() {
    # Exit on error
    set -e
    # if [[ $# -eq 0 ]]; then
    #     echo "No search terms were provided."
    #     exit 1
    # fi
    setup_dirs

    lua "${PROJ_ROOT}/bin/build.lua"
    if [ ! $? -eq 0 ]; then
        echo 'Error: lua had an error building monolith.';
        exit 1;
    fi

    mk_symlink \
        $(realpath "${PROJ_ROOT}/dist/monolith.lua") \
        "${WP_DEFAULT_SCRIPT_DIR}"
    if [ ! $? -eq 0 ]; then exit 1; fi
    mk_symlink \
        $(realpath "${PROJ_ROOT}/lib/wireplumber/wireplumber.conf.d/99-my-script.conf") \
        "${WP_CONFIG_DIR}"
    if [ ! $? -eq 0 ]; then exit 1; fi

    local wp_up=$(is_Uservice_running wireplumber)
    if [ $wp_up -eq 0 ]; then
        echo 'Error: wireplumber.service is running in user context. Consider disabling it.'
        return 1
    fi
    WIREPLUMBER_DEBUG='s-custom:T' wireplumber 2>&1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi

