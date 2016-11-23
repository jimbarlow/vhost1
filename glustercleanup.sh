hosted-engine --set-maintenance --mode=global
sleep 5

gluster volume stop data
gluster volume stop iso
gluster volume stop export
gluster volume stop engine

for i in vhost1 vhost2 vhost3
do 
    ssh root@$i "systemctl stop vdsmd.service"
    ssh root@$i "systemctl disable vdsmd"
done

for i in vhost1 vhost2 vhost3
do 
    ssh root@$i "systemctl stop glusterd.service"
    ssh root@$i "systemctl disable glusterd.service"
done

for i in vhost1 
do 
    ssh root@$i "systemctl stop iptables.service"
    ssh root@$i "systemctl disable iptable.service"
done

for i in vhost1 vhost2 vhost3
do 
    ssh root@$i "systemctl disable glusterd"
done
for i in vhost1 vhost2 vhost3
do
    for b in engine iso data export
    do
        echo $i
        ssh root@$i "umount /dev/mapper/gluster-$b"
    done
done    
# remove the logical volumes
echo "Now beginning for loop in lvremove"
for i in vhost1 vhost2 vhost3
do
    for b in engine iso data export
    do
        echo $i
        echo "root@$i" "lvremove /dev/mapper/gluster-$b"
        ssh root@$i "lvremove /dev/mapper/gluster-$b"
    done
done
# remove the rest of the gluster names in /dev/mapper
for i in vhost1 vhost2 vhost3
do
    ssh root@$i "rm /dev/mapper/gluster*"
done
# remove settings files

# remove the rest of the gluster software in /dev/mapper
for i in vhost1 vhost2 vhost3
do
    ssh root@$i "yum erase -y glusterfs-server"
done
for i in vhost1 vhost2 vhost3
do
   ssh root@$i "rm -rf /var/lib/glusterd"
done    
for i in vhost1 vhost2 vhost3
do
   ssh root@$i "rm -rf /etc/systemd/system/gluster*"
done    
# remove the rest of the vdsm software in /dev/mapper
for i in vhost1 vhost2 vhost3
do
    ssh root@$i "yum erase -y vdsm*"
done
# remove the rest of the vdsm settings and files
for i in vhost1 vhost2 vhost3
do
    ssh root@$i "rm -rf /etc/vdsm* ; rm -rf /var/lib/vdsm* ; rm -rf /etc/ovirt* ; rm -rf /etc/libvirt/qemu/networks/vdsm* ; rm -rf /etc/libvirt/qemu/networks/autostart/vdsm*"
done

for i in vhost1 vhost2 vhost3
do
    ssh root@$i "rm -rf /etc/sysconfig/network-scripts/*ovirtmgmt*"
done

for i in vhost1 vhost2 vhost3
do
    ssh root@$i "cp -f /root/orig*eno1 /etc/sysconfig/network-scripts/ifcfg-eno1"
done

for i in vhost1 vhost2 vhost3
do
    ssh root@$i "rm -rf /etc/systemd/system/gluster.service.d"
done

for i in vhost1 vhost2 vhost3
do
    echo "Cleaning up run directory"
    ssh root@$i "rm -rf /run/vdsm* ; rm -rf /run/gluster* ; rm -rf /run/ovirt*"
done

for i in vhost3 vhost2 vhost2
do 
    ssh root@$i "systemctl restart network"
done

for i in vhost3 vhost2 vhost2
do 
    ssh root@$i "rm -rf /log/vdsm* ; rm -rf /log/gluster*"
done

for i in vhost3 vhost2 vhost2
do 
    ssh root@$i "rm -rf /etc/pki/vdsm* ; rm -rf /etc/pki/libvirt*"
done
