#!/system/bin/sh
export PATH=/system/bin:/system/xbin:$PATH
BLOCK_DEVICE=$1
MOUNT_POINT=$2
LOG_FILE="/dev/null"
LOG_LOCATION="/data/.fsck_log/"

# storage log
if [ "${MOUNT_POINT}" == "/storage_int" ]; then
    mkdir ${LOG_LOCATION}
    busybox find /data/.fsck_log/ -type f -mtime +7  -exec rm {} \;
    TIMESTAMP=`date +%F_%H-%M-%S`
    LOG_FILE=${LOG_LOCATION}/storage_${TIMESTAMP}.log
fi

DATA=`/sbin/blkid /dev/block/mmcblk0p26 | grep "f2fs"`

# mount partition
if [ -e ${BLOCK_DEVICE} ]; then
	if [ "${DATA}" != "" ]; then
		 mount -t f2fs -o rw,noatime,nosuid,nodev,discard,nodiratime,inline_xattr,inline_data,flush_merge ${BLOCK_DEVICE} ${MOUNT_POINT}
	else
		 mount -t ext4 -o noatime,nosuid,nodev,barrier=1,noauto_da_alloc ${BLOCK_DEVICE} ${MOUNT_POINT}
	fi;

fi

NO_HIDE="$(getprop ro.keep.recovery.partition)"
if [ "${NO_HIDE}" != "1" ]; then
    # hide recovery partition
    RECOVERY_NODE="$(busybox readlink -f /dev/block/platform/msm_sdcc.1/by-name/recovery)"
    busybox mv "${RECOVERY_NODE}" /dev/recovery_moved
    busybox mknod -m 0600 "${RECOVERY_NODE}" b 1 3
fi
