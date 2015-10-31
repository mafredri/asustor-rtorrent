#!/usr/bin/env zsh

print "Requesting sudo to establish session..."
sudo echo -n

sshc() {
    ssh asustorx 'zsh -s' <<<$@ 2>/dev/null
}

typeset -A arch_list
arch_list=(
    x86-64 /cross/x86_64-asustor-linux-gnu
    i386 /cross/i686-asustor-linux-gnu
    arm /cross/arm-marvell-linux-gnueabi
)

script_path=${(%):-%x}
script_dir_path=${script_path:A:h}
script_dir_name=${script_dir_path:t}

package=${script_dir_name%-apkg}

print "Building $package"
cd -q $script_dir_path

version=$(<version.txt)

build_apk='build/apk'
build_files='build/files'

[[ -d $build_apk ]] && rm -r $build_apk
mkdir -p $build_apk/.arch
mkdir -p $build_files
mkdir -p dist

print "Copying APK skeleton"
rsync -a source/ $build_apk

for arch prefix in ${(kv)arch_list}; do
    files=(${(@n)$(<files.txt)})
    pfiles=($prefix$^files)

    remote_files=(${(@n)$(sshc ls $pfiles)})

    {
        sshc ROOT=$prefix equery b ${remote_files/$prefix/} | sort | uniq > pkgversions_$arch.txt &&
        print "Wrote pkgversions_$arch.txt" || print "Failed writing pkgversions_$arch.txt"
    } &!

    rsync -a --relative asustorx:"$pfiles" $build_files 2>/dev/null &&
    print "Fetched files for $arch" || print "Failed fetching files for $arch"

    print "Copying $arch files to $build_apk/.arch/$arch..."
    rsync -a $build_files$prefix/ $build_apk/.arch/$arch
done

arch='any'

print "Finalizing..."
print "Setting version to $version and arch to $arch"
sed -i '' -e "s^ARCH^${arch}^" \
    -e "s^VERSION^${version}^" \
    $build_apk/CONTROL/config.json

echo "Building APK..."
# APKs require root privileges, make sure priviliges are correct
sudo chown -R 0:0 $build_apk
sudo apkg-tools.py create $build_apk --destination dist/
sudo chown -R "$(whoami)" dist

# Reset permissions on working directory
sudo chown -R "$(whoami)" $build_apk

echo "Done!"

