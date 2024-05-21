  tc qdisc add dev enp0s3 ingress
 # tc filter add dev enp0s3 parent ffff: prio 4 protocol ip \
#	u32 \
#	match ip protocol 6 0xff \
#	match ip dport 49001 0xffff \
#	flowid 1:1 \
#	action drop
tc filter add dev enp0s3 parent ffff: prio 4 protocol ip \
	u32 \
	match ip 192.168.1.1 \
	flowid 1:1 \
	action drop
