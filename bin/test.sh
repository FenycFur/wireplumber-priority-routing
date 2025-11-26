#!/bin/bash
# Test configuration

PROJ_ROOT=$(dirname $(dirname "${BASH_SOURCE[0]}") )
WP_DEFAULT_SCRIPT_DIR="$HOME/.local/share/wireplumber/scripts/" # TODO: configurable?
WP_CONFIG_DIR="$HOME/.config/wireplumber/wireplumber.conf.d/"

function create_dir() {
    local dirname=$1
    if [[ -z "${dirname}" ]]; then
        return 1
    fi
    
    if [ ! -e "${dirname}" ]; then
        # TODO: what if something before $dirname exists and is a file, and a dir cannot be made?
        mkdir -p "${dirname}"
        return 0
    fi
    if [ -d "${dirname}" ]; then
        return 0
    fi

    echo "'${dirname}' exists and is not a directory! Cannot proceed."
}

function setup_dirs() {
    create_dir "${WP_DEFAULT_SCRIPT_DIR}"
    create_dir "${WP_CONFIG_DIR}"
    # create_dir "test.sh"
    echo hi
    exit 0
}

function main() {
    # Exit on error
    set -e
    # if [[ $# -eq 0 ]]; then
    #     echo "No search terms were provided."
    #     exit 1
    # fi
    setup_dirs
    exit 0

    ln -s "${PROJ_ROOT}/lib/script/linking-mic.lua"
    ln -s "${PROJ_ROOT}/lib/wireplumber/wireplumber.conf.d/99-my-script.conf"
    WIREPLUMBER_DEBUG='s-custom:T' wireplumber 2>&1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi

