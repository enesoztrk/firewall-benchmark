#!/bin/bash
# Set terminal and output file

gnuplot << EOF 
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 800, 600

set title "Deny All throughput"
set xlabel "Mbs"
set ylabel "# of Rules"
set yrange [0:4000]

# Set xtics and boxwidth
set style data histogram
set style histogram cluster gap 1
set xtics ("January" 20, "February" 40, "March" 60, "April" 80, "May" 100)
set boxwidth 0.9
set grid ytics

# Set style fill
set style fill solid 1.0 border -1

# Colors for different datasets
colors = "red blue green cyan skyblue" 

# Legend
set key inside right top vertical Left reverse enhanced autotitles columnhead nobox

# Plot data from files
set output "bar_chart.png"
plot 'iptables-legacy/deny_all_throughput_tcp.dat' using 2:xtic(1) title "iptables-legacy" linecolor rgb "red", \
     'iptables-legacy/deny_all_memory.dat' using 2:xtic(1) title "nftables" linecolor rgb "green", \
     'iptables-legacy/deny_all_memory_2.dat' using 2:xtic(1) title "tc" linecolor rgb "blue", \
     'iptables-legacy/deny_all_memory_2.dat' using 2:xtic(1) title "nfset" linecolor rgb "cyan", \
     'iptables-legacy/deny_all_memory_2.dat' using 2:xtic(1) title "tc-bpf-aya" linecolor rgb "skyblue"


EOF
