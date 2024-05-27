# firewall-benchmark

## Server side
```iperf3 -s -p 1025 -f m```

## Client side
1. Generating rules for iptables,nftables and tc-aya programs: ```./generate_rules.sh```
2. Run iptables tests: ```./iptables_legacy_test.sh <Server IP>```
3. Run nftables tests: ```./nftables_test.sh <Server IP>```
4. Run tc-aya tests: ```./tc_aya_test.sh <Server IP>```
5. Plotting: ```./run_tests.sh```
