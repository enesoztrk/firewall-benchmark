#!/bin/bash
mkdir out
draw_bar_chart(){

local TEST_NAME=$1
local TEST_TYPE=$2
local X_LABEL=$3
local Y_LABEL=$4
local RANGE=$5
local IPTABLES_FILE="iptables-legacy/${TEST_NAME}_${TEST_TYPE}.dat"
local NFTABLES_FILE="nftables/${TEST_NAME}_${TEST_TYPE}.dat"
local TC_AYA_FILE="tc_aya/${TEST_NAME}_${TEST_TYPE}.dat"
local CHART_NAME="out/${TEST_NAME}_${TEST_TYPE}.png"

gnuplot << EOF 
set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 800, 600

set title "${TEST_NAME//_/ }"
set xlabel "Number of rules"
set ylabel "${Y_LABEL}"
set yrange $RANGE

# Set xtics and boxwidth
set style data histogram
set style histogram cluster gap 1
set xtics ("January" 0, "February" 40, "March" 60, "April" 80, "May" 100)
set boxwidth 0.9
set grid ytics

# Set style fill
set style fill solid 1.0 border -1

# Colors for different datasets
colors = "red blue green cyan skyblue" 

# Legend
set key inside right top vertical Left reverse enhanced autotitles columnhead nobox

# Plot data from files
set output "$CHART_NAME"
plot '$IPTABLES_FILE' using 2:xtic(1) title "iptables-legacy" linecolor rgb "red", \
     '$NFTABLES_FILE' using 2:xtic(1) title "nftables" linecolor rgb "green", \
     '$TC_AYA_FILE' using 2:xtic(1) title "tc-aya" linecolor rgb "blue" \


EOF


}
 # 'tc/$TEST_NAME_$TEST_TYPE.dat' using 2:xtic(1) title "tc" linecolor rgb "blue", \
 #    'nfset/$TEST_NAME_$TEST_TYPE.dat' using 2:xtic(1) title "nfset" linecolor rgb "cyan", \
 #    'tc-bpf-aya/$TEST_NAME_$TEST_TYPE.dat' using 2:xtic(1) title "tc-bpf-aya" linecolor rgb "skyblue"

# Main function
main() {
    echo "Tests are running..."
    #bash ./nftables_test.sh
    #sleep 10
    #bash ./iptables_legacy_test.sh
    #sleep 2
    draw_bar_chart "deny_all" "throughput_tcp" "" "Mb/sec" "[0:6000]"
    draw_bar_chart "deny_all" "cpu" "" "CPU(%)" "[0:100]"
    draw_bar_chart "deny_all" "latency" "" "latency(s)" "[0:15]"

}

# Execute main function
main

