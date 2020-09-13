#!/bin/bash
#
# Quick 'n' dirty script to make a chroot environment.
#
# Usage:
#
#     ./makechroot.sh

# List of programs to include in the chroot environment.
programs=(
    sh
    bash
    which
    ls
    mkdir
    rmdir
    cp
    rm
    touch
    mount
    umount
    sleep
    ps
)

# We'll not only need those programs, but their dependencies, too.
declare ldd_cmd ldd_args dep_pattern
if [ "$(which ldd)" ]; then # Linux has shared objects.
    ldd_cmd="ldd"
    dep_pattern="(/usr)?/lib.*\\.[[:digit:]]+"
elif [ "$(which otool)" ]; then # The `otool` command is a macOS-ism.
    ldd_cmd="otool"
    ldd_args="-L" # It takes an argument.
    dep_pattern="\\/usr\\/lib.*dylib"
    # On macOS, we also need to copy the dynamic linker.
    programs+=(/usr/lib/dyld)
fi

# A chroot environment needs a directory to become its new root directory.
newroot="$(mktemp -d chroot-example.d.XXXX)"
cd "$newroot"

# Function: copy_deps_deep
#
# Given a program or library object's file path, look for dependencies
# that program has, and copy their filesystem position over, too.
copy_deps_deep () {
    local file="$1" # Path to the object to examine for dependencies.
    local before="$(mktemp /tmp/newroot-fs-before.XXXX)"
    local after="$(mktemp /tmp/newroot-fs-after.XXXX)"

    find . -xdev | sort > "$before" # Snapshot filesystem start state.

    local deps="$($ldd_cmd $ldd_args "$file" | grep -oE "$dep_pattern")"
    for dep in $deps; do
        mkdir -p $(dirname $dep | sed -e 's/^\///')
        cp -n "$dep" $(echo $dep | sed -e 's/^\///')
    done

    find . -xdev | sort > "$after" # Snapshot filsystem end state.

    # Compare filesystem differences.
    local lines=$(diff -daU 0 "$before" "$after" | grep -vE '^(@@|\+\+\+|---)')
    local x="$?" # Retain the exit status of the `grep` command.

    rm -f "$before" "$after" # Clean up the temporary files.

    if [ $x -eq 1 ]; then
        return # No filesystem differences, so no need to recurse.
    else
        # Turns out a dependency had its own dependency, so recurse.
        for dep in $lines; do
            if [ -f "${dep#+}" ]; then
                echo "Copying dependencies of ${dep#+} ..."
                copy_deps_deep "${dep#+}"
            fi
        done
    fi
}

for program in "${programs[@]}"; do
    echo -n "Copying $program ... "
    basedir=$(dirname $(which "$program") | sed -e 's/^\///')
    mkdir -p "$basedir" && cp -v "$(which "$program")" "$basedir/${program##/*}"

    echo "Copying $program dependencies ..."
    deps="$($ldd_cmd $ldd_args $(which "$program") | grep -oE "$dep_pattern")"
    for dep in $deps; do
        mkdir -p $(dirname $dep | sed -e 's/^\///')
        cp -n "$dep" $(echo $dep | sed -e 's/^\///')
        copy_deps_deep "$dep" # Recursively find additional dependencies.
    done
done

echo
echo "Done! New root is: $newroot"
echo
echo "To start a shell in the chroot environment, invoke the command:"
echo
echo "    sudo chroot $newroot /bin/bash"
echo
