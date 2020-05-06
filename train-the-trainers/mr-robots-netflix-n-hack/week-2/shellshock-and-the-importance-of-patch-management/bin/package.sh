#!/bin/bash
#
# This is a simple utility script whose purpose is simply to document
# how to create a Vagrant Base Box out of the raw sources in the `src`
# directory for this lab environment.
#
# This should probably not need to happen a lot, but hey, if it ever
# does, at least we'll know how the fuck we did it.

set -e
[ -n "$DEBUG" ] && set -x

files=()

usage () {
    echo "Usage: ./bin/package.sh"
    echo
    echo "Be certain you are in the appropriate directory first."
    echo "(The appropriate directory has the 'src' subdirectory."
}

main () {
    local old_pwd="$(pwd)"
    [ ! -d src ] && usage && exit 1
    cd src

    for i in $(ls); do
        case "$i" in
            Vagrantfile|box.ovf|info.json|metadata.json)
                files+=("$i")
                ;;
            *)
                echo "Skipping unrecognized file '$i' ..." 1>&2
                ;;
        esac
    done

    tar -cvzf ../shellshock.box "${files[@]}"

    # Return to where we were when we started.
    cd "$old_pwd"
}

main "$@"
