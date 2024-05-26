#!/bin/bash

FOLDER_NAME="iptables-legacy"
RULE_FOLDER="iptables_rules"
SAMPLING_NUM=100
PING_NUM=30
SCALE=254
SERVER_IP=$1
RULES_FILES=(
    "1_iptable_rules"
    "10_iptable_rules"
    "100_iptable_rules"
    "1000_iptable_rules"
    "10000_iptable_rules"
    "100000_iptable_rules"
    "1000000_iptable_rules"
)

# Function to measure network throughput using iperf
tcp_measure_throughput() {
    echo "TCP-Measuring network throughput..."

    # Run iperf client to measure throughput
    if [ "$3" == "cpu" ]; then
        echo "Third argument is 'cpu'" 
       host_total=$( iperf3 -c $SERVER_IP -p 1025 -O 2 -t $SAMPLING_NUM -i 1 -A 2  -b 1G -J  | jq -r '.end.cpu_utilization_percent.host_total')
       printf "$1 $host_total\n" >> $FOLDER_NAME/$2_cpu.dat
    else
        echo "Third argument is not 'cpu'"
        throughput_sender=$(iperf3 -c $SERVER_IP -p 1025 -O 2 -t $SAMPLING_NUM -i 1 -A 2 -f m| grep "sender" |  grep -oP '\d+\sMbits\/sec' | sed 's/ Mbits\/sec//')
          printf "$1 $throughput_sender\n" >> $FOLDER_NAME/$2_throughput_tcp.dat
    fi
   # throughput_receiver=$(iperf3 -c 192.168.1.8 -p 1025 -t 10 -i 1 -bidir | grep "receiver" | grep -oP '\d+\.\d+\sGbits\/sec')
   # throughput_sender=$(netperf -H 192.168.1.8  -l 100 -t TCP_STREAM | tail -1 | awk '{print $5}')
  
   # echo "Receiver Throughput (Mbps): $throughput_receiver" >> results.txt

}

udp_measure_throughput() {
    echo "UDP-Measuring network throughput..."

    # Run iperf client to measure throughput
    throughput_sender=$(iperf3 -c $SERVER_IP -p 1025 -O 2 -t $SAMPLING_NUM -i 1 -A 2 -f m -u| grep "sender" |  grep -oP '\d+\sMbits\/sec' | sed 's/ Mbits\/sec//')
   # throughput_receiver=$(iperf3 -c 192.168.1.8 -p 1025 -t 10 -i 1 -bidir | grep "receiver" | grep -oP '\d+\.\d+\sGbits\/sec')
   # throughput_sender=$(netperf -H 192.168.1.8  -l 100 -t TCP_STREAM | tail -1 | awk '{print $5}')
    printf "$1 $throughput_sender\n" >> $FOLDER_NAME/$2_throughput_udp.dat
   # echo "Receiver Throughput (Mbps): $throughput_receiver" >> results.txt

}


# Function to measure network latency using ping
measure_latency() {
    echo "Measuring network latency(ms)..."
    latency=$(ping -c $PING_NUM $SERVER_IP | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
    printf "$1 $latency\n" >> $FOLDER_NAME/$2_latency.dat
}

# Function to measure CPU utilization
measure_cpu_utilization() {
    echo "Measuring CPU utilization..."
    cpu_utilization=$(top -n 1 | grep "Cpu(s)" | awk '{gsub(/,/,".",$8); print 100 - $8}')
    printf "$1 $cpu_utilization\n" >> $FOLDER_NAME/$2_cpu.dat
}

# Function to measure memory consumption
measure_memory_consumption() {
    echo "Measuring memory consumption...(Mb)"
    memory_consumption=$(free -m | grep Mem | awk '{print $3}' | sed 's/Gi//')
    printf "$1 $memory_consumption\n" >> $FOLDER_NAME/$2_memory.dat
}




reset_iptables_rules(){
 iptables -F
 iptables -F test_input
 iptables -X 
 iptables -P INPUT DROP
 iptables -P OUTPUT DROP
}


deny_all_iptables() {
SCALE_INDEX=$(( $1 % 254 ))
if [[ $SCALE_INDEX -eq -1 ]]; then
        iptables -A OUTPUT -j ACCEPT
        iptables -N test_input
        iptables -A INPUT -j test_input
        iptables -A INPUT -j ACCEPT
else
        iptables -A test_input -s 10.11.100.$SCALE_INDEX -j DROP
fi
}
# Test scenarios

deny_all_test_tcp(){
    echo "Deny All Traffic"
   local total_num_rule=0  # Remove spaces around the equals sign

for file in "${RULES_FILES[@]}"; do
    
    total_num_rule=$(echo "$file" | grep -o '^[0-9]\+')
     echo "ip-restore $RULE_FOLDER/$file"
    iptables-restore < "$RULE_FOLDER/$file"
    tcp_measure_throughput "$total_num_rule" "deny_all"
    measure_latency "$total_num_rule" "deny_all"
    measure_memory_consumption "$total_num_rule" "deny_all"
done

   

}

deny_all_test_cpu_tcp(){
    echo "Deny All Traffic CPU measurement"
    local total_num_rule=0  # Remove spaces around the equals sign
    
  for file in "${RULES_FILES[@]}"; do
    total_num_rule=$(echo "$file" | grep -o '^[0-9]\+')
     echo "ip-restore $RULE_FOLDER/$file"
    iptables-restore < "$RULE_FOLDER/$file"
    tcp_measure_throughput "$total_num_rule" "deny_all" "cpu"
    done
}


reset_interface(){
ifconfig enp0s3 down
sleep 1
ifconfig enp0s3 up
}

# Main function
main() {
    nix-env --uninstall iptables 
    nix-env -iA nixos.iptables-legacy
    sleep 1
    iptables
    echo "Benchmarking iptables..."
    rm -rf "$FOLDER_NAME-old"
    mv $FOLDER_NAME "$FOLDER_NAME-old"
    mkdir  $FOLDER_NAME
   # reset_interface
    deny_all_test_cpu_tcp
   # reset_interface
    deny_all_test_tcp
   
    nix-env --uninstall iptables 
}

# Execute main function
main
