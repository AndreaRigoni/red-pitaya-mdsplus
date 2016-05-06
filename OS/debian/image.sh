#!/bin/bash 
# (can not use sh because of the uncompatible ubuntu dash)

# //////////////////////////////////////////////////////////////////////////// #
# // CONFIG ////////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

srcdir=${srcdir:=.}
top_srcdir=${top_srcdir:=.}
DATE=`date +"%H-%M-%S_%d-%b-%Y"`


set -x 
ARCH=${ARCH:=armhf} # the ABI (armel/armhf)
SIZE=${SIZE:=3500}  # default image size if 3GB, ok for all 4BG SD cards
IMAGE=${IMAGE:=debian_${ARCH}_${DATE}.img}
OVERLAY=${OVERLAY:=overlay}
ECOSYSTEM_ZIP=${ECOSYSTEM_ZIP:?}
BOOT_DIR=boot
ROOT_DIR=root   
set +x

# //////////////////////////////////////////////////////////////////////////// #
# // ARGS PARSE ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

SCRIPTNAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")

print_help() {
cat << EOF

Usage: $SCRIPTNAME [options]

       options
       -------
       -h|--help          get this help      
       -c|--config        set distribution config file
       -v|--verbose       show script source script
       -s|--size          image size (default 3Gb)
       -a|--arch          architecture (default armhf)
       -i|--image         image name (default debian_${ARCH}_${DATE}.img)
       -o|--overlay       system overlay to be applied
       -e|--ecosystem     ecosystem zip file

EOF
}

## parse cmd parameters:
while [[ "$1" == -* ]] ; do
	case "$1" in
		-h|--help)
			print_help
			exit
			;;
		-c|--config)
		        CONFIG_FILE=$2
			shift 2
			;;
			
		-s|--size)
		        SIZE=$2
			shift 2
			;;

		-a|--arch)
		        ARCH=$2
			shift 2
			;;

		-i|--image)
		        IMAGE=$2
			shift 2
			;;
			
		-o|--overlay)
		        OVERLAY=$2
			shift 2
			;;
			

	        -v|--verbose)
		        set -o verbose
			shift
			;;
		--)
			shift
			break
			;;
		*)
		        break
			;;
	esac
done

#if [ $# -lt 1 ] ; then
#	echo "Incorrect parameters. Use --help for usage instructions."
#	exit 1
#fi

# evaluate config file if any
if [ ${CONFIG_FILE} -a -f ${CONFIG_FILE} ]; then 
 source ${CONFIG_FILE}
fi




# //////////////////////////////////////////////////////////////////////////// #
# // FUCTIONS   ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


check_command() {  
  hash $1 2>/dev/null
}



# //////////////////////////////////////////////////////////////////////////// #
# // CREATE AND MOUNT DEVICE   /////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

mount_image() {

  if [ ! -f ${IMAGE} ]; then 
   dd if=/dev/zero of=$IMAGE bs=1M count=$SIZE  
   DEVICE=`losetup -f`
   losetup $DEVICE $IMAGE

   # Create partitions
   check_command parted
   parted -s $DEVICE mklabel msdos
   parted -s $DEVICE mkpart primary fat16   4MB 128MB
   parted -s $DEVICE mkpart primary ext4  128MB 100%
   
   BOOT_DEV=/dev/`lsblk -lno NAME $DEVICE | sed '2!d'`
   ROOT_DEV=/dev/`lsblk -lno NAME $DEVICE | sed '3!d'`

   # Create file systems
   check_command mkfs.vfat
   check_command mkfs.vfat  
   mkfs.vfat -v    $BOOT_DEV
   mkfs.ext4 -F -j $ROOT_DEV
   
  else
    DEVICE=`losetup -f`
    losetup $DEVICE $IMAGE  
    BOOT_DEV=/dev/`lsblk -lno NAME $DEVICE | sed '2!d'`
    ROOT_DEV=/dev/`lsblk -lno NAME $DEVICE | sed '3!d'`    
  fi

  # Mount file systems
  mkdir -p $BOOT_DIR $ROOT_DIR
  mount $BOOT_DEV $BOOT_DIR
  mount $ROOT_DEV $ROOT_DIR

}

umount_image() {
  DEVICE=${DEVICE:=$(losetup -a | grep ${IMAGE} | awk '{print $1}' | sed 's/://')}
  if [ ${DEVICE} -a ${BOOT_DIR} -a ${ROOT_DIR} ]; then
    umount $BOOT_DIR $ROOT_DIR
    rmdir --ignore-fail-on-non-empty $BOOT_DIR 
    rmdir --ignore-fail-on-non-empty $ROOT_DIR
    echo "unmounting device ${DEVICE}"
    losetup -d $DEVICE
  fi
}

is_mounted() {  
  check_command mountpoint || (echo "mountpoint command not found"; exit 1)
  if [ -d ${BOOT_DIR} -a -d ${ROOT_DIR} ]; then
    mountpoint -q ${BOOT_DIR} && mountpoint -q ${ROOT_DIR} && return 0
  fi
  return 1
}

# //////////////////////////////////////////////////////////////////////////// #
# // INSTALL    ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

# // install OS //
install_debian() {
  is_mounted || mount_image
  # enable chroot access with native execution
  mkdir -p $ROOT_DIR/etc
  mkdir -p $ROOT_DIR/usr/bin
  cp /etc/resolv.conf         $ROOT_DIR/etc/
  cp /usr/bin/qemu-arm-static $ROOT_DIR/usr/bin/

  . ${srcdir}/debian.sh

  # disable chroot access with native execution
  rm $ROOT_DIR/etc/resolv.conf
  rm $ROOT_DIR/usr/bin/qemu-arm-static
  
}


install_ecosystem() {
  is_mounted || mount_image
  # enable chroot access with native execution
  mkdir -p $ROOT_DIR/etc
  mkdir -p $ROOT_DIR/usr/bin
  cp /etc/resolv.conf         $ROOT_DIR/etc/
  cp /usr/bin/qemu-arm-static $ROOT_DIR/usr/bin/

  . ${srcdir}/redpitaya.sh

  # disable chroot access with native execution
  rm $ROOT_DIR/etc/resolv.conf
  rm $ROOT_DIR/usr/bin/qemu-arm-static
}




# //////////////////////////////////////////////////////////////////////////// #
# // CMD        ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

$@



