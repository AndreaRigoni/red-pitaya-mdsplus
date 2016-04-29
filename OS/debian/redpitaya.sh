################################################################################
# Authors:
# - Pavel Demin <pavel.demin@uclouvain.be>
# - Iztok Jeras <iztok.jeras@redpitaya.com>
# License:
# https://raw.githubusercontent.com/RedPitaya/RedPitaya/master/COPYING
################################################################################

set -x

# Makefile dependency
srcdir=${srcdir:?}
top_srcdir=${top_srcdir:?}


# Copy files to the boot file system
unzip ${ECOSYSTEM_ZIP} -d $BOOT_DIR

# Systemd services
install -v -m 664 -o root -D $OVERLAY/etc/sysconfig/redpitaya                        $ROOT_DIR/etc/sysconfig/redpitaya

chroot $ROOT_DIR <<- EOF_CHROOT
apt-get -y install libboost-system1.55.0 libboost-regex1.55.0 libboost-thread1.55.0
EOF_CHROOT

# profile for PATH variables, ...
install -v -m 664 -o root -D $OVERLAY/etc/profile.d/profile.sh   $ROOT_DIR/etc/profile.d/profile.sh
install -v -m 664 -o root -D $OVERLAY/etc/profile.d/alias.sh     $ROOT_DIR/etc/profile.d/alias.sh
install -v -m 664 -o root -D $OVERLAY/etc/profile.d/redpitaya.sh $ROOT_DIR/etc/profile.d/redpitaya.sh

