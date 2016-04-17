#cd ../../..
#mkdir -p out/target/product/sprout4/conv/
#chmod a+x out/target/product/sprout4/conv/
#cp out/target/product/sprout4/boot.img out/target/product/sprout4/conv/
#cp -R external/Sprout/48c/mkboot/ out/target/product/sprout4/conv/
#cp external/Sprout/48c/extract-kernel.pl out/target/product/sprout4/conv
#cp external/Sprout/48c/extract-ramdisk.pl out/target/product/sprout4/conv
#cp -R external/Sprout/48c/prop out/target/product/sprout4/conv
#cd out/target/product/sprout4
#cp boot.img conv/boot.img
#cd conv
#chmod a+x extract-kernel.pl
#chmod a+x extract-ramdisk.pl
./extract-kernel.pl boot.img 2>/dev/null
./extract-ramdisk.pl boot.img 2>/dev/null
cd boot.img-ramdisk
rm init.sprout.rc
rm fstab.sprout
cd ..
cp prop/* boot.img-ramdisk/
base_dir=`pwd`
working_folder=`pwd`
#compile_mkboot
cd mkboot
mkbootimg_src=mkbootimg_mt65xx.c
mkbootimg_out=mkbootimg
mkbootfs_file=mkbootfs
mkbootimg_file=mkbootimg_out
gcc -o mkbootfs mkbootfs.c
if [ -e $mkbootimg_file ]
then
rm -rf $mkbootimg_file
fi
gcc -c rsa.c
gcc -c sha.c
gcc rsa.o sha.o mkbootimg_mt65xx.c -w -o $mkbootimg_out
cd ..
cp mkboot/mkbootimg mkbootimg
cp mkboot/$mkbootfs_file $mkbootfs_file
./$mkbootfs_file boot.img-ramdisk | gzip > ramdisk.gz
base_temp=`od -A n -h -j 14 -N 2 boot.img | sed 's/ //g'`
zeros=0000
base=0x$base_temp$zeros
temp=`od -A n -H -j 20 -N 4 boot.img | sed 's/ //g'`
ramdisk_load_addr=0x$temp
ramdisk_addr=ramdisk_load_addr
mkdir -p old_boot
mv boot.img old_boot/boot.img
ramdisk_params=""
./mkbootimg --kernel zImage --ramdisk ramdisk.gz -o boot.img --base $base $ramdisk_params
if [ -e boot.img ]
then
echo "Success!"
fi
cd ..
rm *.zip
rm boot.img
cp conv/boot.img boot.img
brunch sprout4
