# stripe pool RAID 0
sudo zpool create dbstorage /dev/sdb /dev/sdc -o ashift=12

# mirror pool RAID 1
sudo zpool create data mirror /dev/sdb /dev/sdc

# mount on a different mount point
sudo zpool create -m /usr/share/pool data mirror /dev/sdb /dev/sdc

# create filesystem
sudo zfs create data/database

# status
sudo zpool status

# destro pool
sudo zpool destroy data

# add a new disk
sudo zpool add data /dev/sdd

# check data integrity
sudo zpool scrub data
zpool status -v data

# show data statistics
zpool iostat -v

##Continuous monitor every 5 seconds
zpool iostat -v 5
