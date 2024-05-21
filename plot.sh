#!/bin/bash

# Gnuplot script
gnuplot << EOF
set terminal png
set output "output.png"
set title "Deny All Traffic Throughput"
set xlabel "# Number of Rules"
set ylabel "Mbits/sec"
plot "deny_all.dat" using 1:2 with lines title "Throughput (iptables)", \
     "tc_deny_all.dat" using 1:2 with lines title "Throughput (tc)"
EOF