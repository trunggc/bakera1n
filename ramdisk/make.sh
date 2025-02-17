#!/bin/sh

VERSION_FLAG=$1

VOLUME="kok3shird"

rm -rf $VOLUME/
rm -rf ramdisk.dmg
rm -rf build/

mkdir $VOLUME/
mkdir build/

cd $VOLUME


# create fs dir
mkdir fs/
mkdir fs/gen/
#mkdir fs/fake/
mkdir fs/orig/
mkdir binpack/

mkdir Applications/
mkdir Developer/
mkdir Library/
mkdir System/
mkdir bin/
mkdir cores/
mkdir dev/
mkdir private/
mkdir sbin/
mkdir usr/

mkdir private/etc/
mkdir private/preboot/
mkdir private/system_data/
mkdir private/var/
mkdir private/xarts/
mkdir private/var/tmp

chown root:wheel fs/
chown root:wheel fs/gen/
chown root:wheel fs/orig/
chown root:wheel binpack/
chmod 0755 fs/
chmod 0755 fs/gen/
chmod 0755 fs/orig/
chmod 0755 binpack/

chown root:admin Applications/
chown root:admin Developer/
chown root:wheel Library/
chown root:wheel System/
chown root:wheel bin/
chown root:admin cores/
chown root:wheel dev/
chown root:wheel private/
chown root:wheel private/etc/
chown root:wheel private/preboot/
chown root:wheel private/system_data/
chown root:wheel private/var/
chown root:wheel private/var/tmp/
chown root:wheel private/xarts/
chown root:wheel sbin/
chown root:wheel usr/

chmod 0775 Applications/
chmod 0775 Developer/
chmod 0755 Library/
chmod 0755 System/
chmod 0755 bin/
chmod 1775 cores/
chmod 0555 dev/
chmod 0755 private/
chmod 0755 private/etc/
chmod 0755 private/preboot/
chmod 0755 private/system_data/
chmod 0755 private/var/
chmod 1777 private/var/tmp/
chmod 0755 private/xarts/
chmod 0755 sbin/
chmod 0755 usr/

ln -s private/etc etc
ln -s private/var/tmp tmp
ln -s private/var var

chown -h root:wheel etc
chown -h root:wheel tmp
chown -h root:admin var
chmod 0755 etc
chmod 0755 tmp
chmod 0755 var

cd ..

cd src/
rm -rf dropbear.h
xxd -i dropbear.plist > dropbear.h
cd ..


# fsutil
cp -a src/fsutil.sh build/fsutil.sh
chmod 0644 build/fsutil.sh

# inject rootless dylib for launchd
xcrun -sdk iphoneos clang -arch arm64 -shared src/payload/libpayload.c -DDEVBUILD=1 -o haxx.dylib
strip haxx.dylib
ldid -S haxx.dylib
xxd -i haxx.dylib > haxx_dylib.h
cd src/
rm -rf haxx_dylib.h
mv -v ../haxx_dylib.h ./
cd ..
mv haxx.dylib $VOLUME/haxx.dylib
cp -a $VOLUME/haxx.dylib build/haxx.dylib
chown root:wheel $VOLUME/haxx.dylib
chmod 0755 $VOLUME/haxx.dylib
chmod 0644 build/haxx.dylib

# inject rootfull dylib for launchd
xcrun -sdk iphoneos clang -arch arm64 -shared src/payload/libpayload.c -DROOTFULL=1 -DDEVBUILD=1 -o haxz.dylib
strip haxz.dylib
ldid -S haxz.dylib
mv haxz.dylib build/haxz.dylib
chmod 0644 build/haxz.dylib

# payload
xcrun -sdk iphoneos clang -arch arm64 src/payload/payload.m src/payload/utils.m -o haxx -Isrc/include/ -framework IOKit -framework CoreFoundation -framework Foundation -DDEVBUILD=1 $VERSION_FLAG
strip haxx
ldid -Ssrc/ent2.xml haxx
xxd -i haxx > haxx.h
cd src/
rm -rf haxx.h
mv -v ../haxx.h ./
cd ..
mv haxx $VOLUME/haxx
cp -a $VOLUME/haxx build/haxx
chown root:wheel $VOLUME/haxx
chmod 0755 $VOLUME/haxx
chmod 0644 build/haxx

# fakelaunchd
cp -a src/launchd $VOLUME/sbin/launchd
ldid -Ssrc/ent.xml $VOLUME/sbin/launchd
cp -a $VOLUME/sbin/launchd build/loaderd
chown root:wheel $VOLUME/sbin/launchd
chmod 0755 $VOLUME/sbin/launchd
chmod 0644 build/loaderd

# fake dyld for rootful
xcrun -sdk iphoneos clang -e__dyld_start -Wl,-dylinker -Wl,-dylinker_install_name,/usr/lib/dyld -nostdlib -static -Wl,-fatal_warnings -Wl,-dead_strip -Wl,-Z --target=arm64-apple-ios12.0 -std=gnu17 -flto -ffreestanding -U__nonnull -nostdlibinc -fno-stack-protector src/fake/dyld_generic.c src/fake/printf.c src/fake/dyld_utils.c -Isrc/include/ -o com.apple.dyld -DDEVBUILD=1 -DROOTFULL=1 $VERSION_FLAG
strip com.apple.dyld
ldid -S com.apple.dyld
mv com.apple.dyld build/fakedyld_rootful
chmod 0644 build/fakedyld_rootful

# fake dyld for rootless
xcrun -sdk iphoneos clang -e__dyld_start -Wl,-dylinker -Wl,-dylinker_install_name,/usr/lib/dyld -nostdlib -static -Wl,-fatal_warnings -Wl,-dead_strip -Wl,-Z --target=arm64-apple-ios12.0 -std=gnu17 -flto -ffreestanding -U__nonnull -nostdlibinc -fno-stack-protector src/fake/dyld_generic.c src/fake/printf.c src/fake/dyld_utils.c -Isrc/include/ -o com.apple.dyld -DDEVBUILD=1 $VERSION_FLAG
strip com.apple.dyld
ldid -S com.apple.dyld
mv com.apple.dyld build/fakedyld_rootless
chmod 0644 build/fakedyld_rootless

# fake dyld
xcrun -sdk iphoneos clang -e__dyld_start -Wl,-dylinker -Wl,-dylinker_install_name,/usr/lib/dyld -nostdlib -static -Wl,-fatal_warnings -Wl,-dead_strip -Wl,-Z --target=arm64-apple-ios12.0 -std=gnu17 -flto -ffreestanding -U__nonnull -nostdlibinc -fno-stack-protector src/fake/dyld_ramdisk.c src/fake/printf.c src/fake/dyld_utils.c -Isrc/include/ -o com.apple.dyld -DDEVBUILD=1 $VERSION_FLAG
strip com.apple.dyld
ldid -S com.apple.dyld
#use custom dyld with dyld_hook
mv com.apple.dyld $VOLUME/fs/gen/dyld
chown root:wheel $VOLUME/fs/gen/dyld
chmod 0755 $VOLUME/fs/gen/dyld

hdiutil create -size 1m -layout NONE -format UDRW -srcfolder ./$VOLUME -fs HFS+ ./ramdisk.dmg

rm -rf $VOLUME/

rm -f src/dropbear.h
rm -f src/haxx_dylib.h
rm -f src/haxx.h
