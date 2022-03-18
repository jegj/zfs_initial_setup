# striped pool
sudo zpool create data /dev/sdb /dev/sdc

# mirror pool
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
