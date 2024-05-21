
#!/bin/bash

# Define file names and prefixes
declare -A RULES_FILES=(
    [1]="1_iptable_rules"
    [10]="10_iptable_rules"
    [100]="100_iptable_rules"
    [1000]="1000_iptable_rules"
    [10000]="10000_iptable_rules"
    [100000]="100000_iptable_rules"
    [1000000]="1000000_iptable_rules"
)

IP_PREFIX="192.168."

# Check if iptables-restore exists
if ! command -v iptables-restore &> /dev/null; then
    echo "iptables-restore could not be found"
    exit 1
fi

# Define the default rules
DEFAULT_RULES="*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT DROP [0:0]
:test - [0:0]
:test_input - [0:0]
-A INPUT -j test_input
-A INPUT -j ACCEPT
-A OUTPUT -j test
-A OUTPUT -j ACCEPT
"

# Iterate over RULES_FILES and write DEFAULT_RULES to each file
for count in "${!RULES_FILES[@]}"; do
    file="${RULES_FILES[$count]}"
    echo -e "$DEFAULT_RULES" > "$file"
done



# Variables to control the exact number of rules
rule_count=0
max_rules=1000000

# Generate 1 rule
echo "-A test -s ${IP_PREFIX}10.1 -j DROP" >> "1_iptable_rules"
echo "-A test_input -s ${IP_PREFIX}10.1 -j DROP" >> "1_iptable_rules"

# Generate 10 rules
for j in $(seq 0 10); do
        echo "-A test -s ${IP_PREFIX}120.${j} -j DROP" >> "10_iptable_rules"
        echo "-A test_input -s ${IP_PREFIX}120.${j} -j DROP" >> "10_iptable_rules"
done

# Generate 100 rules
for j in $(seq 0 100); do
        echo "-A test -s ${IP_PREFIX}130.${j} -j DROP" >> "100_iptable_rules"
        echo "-A test_input -s ${IP_PREFIX}130.${j} -j DROP" >> "100_iptable_rules"
done

# Generate 1K rules
for i in $(seq 2 6); do
    for j in $(seq 0 250); do
        echo "-A test -s ${IP_PREFIX}${i}.${j} -j DROP" >> "1000_iptable_rules"
        echo "-A test_input -s ${IP_PREFIX}${i}.${j} -j DROP" >> "1000_iptable_rules"
    done
done
# Generate 10K rules
for i in $(seq 2 42); do
    for j in $(seq 0 250); do
        echo "-A test -s ${IP_PREFIX}${i}.${j} -j DROP" >> "10000_iptable_rules"
        echo "-A test_input -s ${IP_PREFIX}${i}.${j} -j DROP" >> "10000_iptable_rules"
    done
done

# Generate 100K rules
for k in $(seq 0 2); do
for i in $(seq 2 202); do
    for j in $(seq 0 250); do
        echo "-A test -s ${IP_PREFIX}${i}.${j} -j DROP" >> "100000_iptable_rules"
        echo "-A test_input -s ${IP_PREFIX}${i}.${j} -j DROP" >> "100000_iptable_rules"
    done
done
done 
# 1M Generate rules
for k in $(seq 0 16); do
for i in $(seq 2 255); do
    for j in $(seq 0 255); do
        if [ $rule_count -ge $max_rules ]; then
            break 2
        fi
        echo "-A test -s ${IP_PREFIX}${i}.${j} -j DROP" >> "1000000_iptable_rules"
        echo "-A test_input -s ${IP_PREFIX}${i}.${j} -j DROP" >> "1000000_iptable_rules"

        rule_count=$((rule_count + 1))
    done
done
done 
# Finalize the rules file
#echo "COMMIT" >> $RULES_FILE

# Iterate over RULES_FILES and write DEFAULT_RULES to each file
for count in "${!RULES_FILES[@]}"; do
    file="${RULES_FILES[$count]}"
    echo -e "COMMIT" >> "$file"
done


# Apply the rules
#if sudo iptables-restore < $RULES_FILE; then
#    echo "$rule_count iptables rules have been applied."
#else
#    echo "Failed to apply iptables rules."
#fi
