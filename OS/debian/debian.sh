#!/bin/bash 
################################################################################
# Authors:
# - Pavel Demin <pavel.demin@uclouvain.be>
# - Iztok Jeras <iztok.jeras@redpitaya.com>
# License:
# https://raw.githubusercontent.com/RedPitaya/RedPitaya/master/COPYING
################################################################################

# //////////////////////////////////////////////////////////////////////////// #
# // ARGS PARSE ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

SCRIPTNAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$0")

MIRROR=${MIRROR:=http://ftp.debian.org/debian}
DISTRO=${DISTRO:=jessie}
OVERLAY=${OVERLAY:=overlay}
ROOT_DIR=${ROOT_DIR:=root}
ARCH=${ARCH:=armhf}

# Makefile dependency
srcdir=${srcdir:?}
top_srcdir=${top_srcdir:?}


print_help() {
cat << EOF

Installs debian redpitaya into a specified root directory
Usage: $SCRIPTNAME [options]

       options
       -------
       -h|--help          get this help      
       -c|--config        set distribution config file
       -v|--verbose       show script source script
       -m|--mirror        debian mirror ( $MIRROR )
       -d|--distro        debian distro name ( $DISTRO )
       -o|--overlay       system overlay to be applied
       -r|--root          root directory to install to
       -a|--arch          architecture ( $ARCH )
       
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

		-m|--mirror)
		        MIRROR=$2
			shift 2
			;;

		-d|--distro)
		        DISTRO=$2
			shift 2
			;;
			
		-o|--overlay)
		        OVERLAY=$2
			shift 2
			;;
			
		-r|--root)
		        ROOT_DIR=$2
			shift 2
			;;

		-a|--arch)
		        ARCH=$2
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


# evaluate config file if any
if [ ${CONFIG_FILE} -a -f ${CONFIG_FILE} ]; then 
 source ${CONFIG_FILE}
fi


# setup arm chroot
mkdir -p $ROOT_DIR/etc
mkdir -p $ROOT_DIR/usr/bin
[ -f $ROOT_DIR/etc/resolv.conf ]          || cp /etc/resolv.conf         $ROOT_DIR/etc/
[ -f $ROOT_DIR//usr/bin/qemu-arm-static ] || cp /usr/bin/qemu-arm-static $ROOT_DIR/usr/bin/


# //////////////////////////////////////////////////////////////////////////// #
# // FUNCTIONS  ////////////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #


check_command() {  
  hash $1 2>/dev/null
}


# //////////////////////////////////////////////////////////////////////////// #
# // INSTALL DEBIAN  ///////////////////////////////////////////////////////// #
# //////////////////////////////////////////////////////////////////////////// #

check_command debootstrap
debootstrap --foreign --arch $ARCH $DISTRO $ROOT_DIR $MIRROR

chroot $ROOT_DIR <<- EOF_CHROOT
export LANG=C
/debootstrap/debootstrap --second-stage
EOF_CHROOT


# install kernel modules
mkdir -p $ROOT_DIR/lib
cp -a ${MODULES_PATH}/lib/modules        $ROOT_DIR/lib
chown root:root -R $ROOT_DIR/lib/modules


# copy U-Boot environment tools
install -v -m 664 -o root -D ${top_srcdir}/patches/fw_env.config        $ROOT_DIR/etc/fw_env.config
install -v -m 664 -o root -D $OVERLAY/etc/apt/apt.conf.d/99norecommends $ROOT_DIR/etc/apt/apt.conf.d/99norecommends
install -v -m 664 -o root -D $OVERLAY/etc/apt/sources.list              $ROOT_DIR/etc/apt/sources.list
install -v -m 664 -o root -D $OVERLAY/etc/fstab                         $ROOT_DIR/etc/fstab
install -v -m 664 -o root -D $OVERLAY/etc/hostname                      $ROOT_DIR/etc/hostname
install -v -m 664 -o root -D $OVERLAY/etc/timezone                      $ROOT_DIR/etc/timezone
install -v -m 664 -o root -D $OVERLAY/etc/securetty                     $ROOT_DIR/etc/securetty


# setup locale and timezone, install packages
chroot $ROOT_DIR <<- EOF_CHROOT
# TODO seems sytemd is not running without /proc/cmdline or something
#hostnamectl set-hostname redpitaya
#timedatectl set-timezone Europe/Rome
#localectl   set-locale   LANG="en_US.UTF-8"

apt-get update
apt-get -y upgrade
apt-get -y install locales

sed -i "/^# en_US.UTF-8 UTF-8$/s/^# //" /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

dpkg-reconfigure --frontend=noninteractive tzdata

apt-get -y install openssh-server ca-certificates ntp ntpdate fake-hwclock \
  usbutils psmisc lsof parted curl vim wpasupplicant hostapd isc-dhcp-server \
  iw firmware-realtek firmware-ralink build-essential ifplugd sudo u-boot-tools

sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
EOF_CHROOT

# network configuration
install -v -m 664 -o root -D $OVERLAY/etc/udev/rules.d/75-persistent-net-generator.rules $ROOT_DIR/etc/udev/rules.d/75-persistent-net-generator.rules
install -v -m 664 -o root -D $OVERLAY/etc/default/ifplugd                                $ROOT_DIR/etc/default/ifplugd
# NOTE: the next line is now preformed elsewhere, while preparing the ecosystem ZIP for the FAT partition
#install -v -m 664 -o root -D $OVERLAY/etc/hostapd/hostapd.conf                           $BOOT_DIR/hostapd.conf
install -v -m 664 -o root -D $OVERLAY/etc/default/hostapd                                $ROOT_DIR/etc/default/hostapd
install -v -m 664 -o root -D $OVERLAY/etc/dhcp/dhcpd.conf                                $ROOT_DIR/etc/dhcp/dhcpd.conf
install -v -m 664 -o root -D $OVERLAY/etc/dhcp/dhclient.conf                             $ROOT_DIR/etc/dhcp/dhclient.conf
install -v -m 664 -o root -D $OVERLAY/etc/iptables.ipv4.nat                              $ROOT_DIR/etc/iptables.ipv4.nat
install -v -m 664 -o root -D $OVERLAY/etc/iptables.ipv4.nonat                            $ROOT_DIR/etc/iptables.ipv4.nonat
install -v -m 664 -o root -D $OVERLAY/etc/network/interfaces                             $ROOT_DIR/etc/network/interfaces
install -v -m 664 -o root -D $OVERLAY/etc/network/interfaces.d/eth0                      $ROOT_DIR/etc/network/interfaces.d/eth0
# TODO: the next three files are not handled cleanly, netwoking should be documented and cleaned 
install -v -m 664 -o root -D $OVERLAY/etc/network/interfaces.d/wlan0.ap                  $ROOT_DIR/etc/network/interfaces.d/wlan0.ap
install -v -m 664 -o root -D $OVERLAY/etc/network/interfaces.d/wlan0.client              $ROOT_DIR/etc/network/interfaces.d/wlan0.client
ln -s                                                          wlan0.ap                  $ROOT_DIR/etc/network/interfaces.d/wlan0

chroot $ROOT_DIR <<- EOF_CHROOT
sed -i '/^#net.ipv4.ip_forward=1$/s/^#//' /etc/sysctl.conf
EOF_CHROOT

chroot $ROOT_DIR <<- EOF_CHROOT
echo root:root | chpasswd
apt-get clean
service sshd stop
service ntp stop
EOF_CHROOT

