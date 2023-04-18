#!/bin/bash

rm -f will_exp.txt

tmsh -q -c "cd / ; list sys file recursive ssl-cert expiration-date" > cert.txt

# Set the name of the file to read
file="cert.txt"

# Days to check
DAYS_THRESHOLD=60

# Create a temporary file to store the modified contents for the first loop
temp_file1=$(mktemp)

# Read the file line by line
while read line; do
    # Remove any instances of the words "sys file ssl-cert"
    modified_line=$(echo "$line" | sed 's/sys file ssl-cert//g')
    # Write the modified line to the temporary file
    echo "$modified_line" >> "$temp_file1"
done < "$file"

# Replace the original file with the modified contents
mv "$temp_file1" "$file"

# Create a temporary file to store the modified contents for the second loop
temp_file2=$(mktemp)

while read line; do
    # Remove any instances of the {} characters
    modified_line=$(echo "$line" | sed 's/{\|}//g')
    # Replace any newlines with spaces
    modified_line=$(echo "$modified_line" | tr '\n' ' ')
    # Write the modified line to the temporary file
    echo "$modified_line" >> "$temp_file2"
done < "$file"

# Replace the original file with the modified contents
mv "$temp_file2" "$file"

temp_file3=$(mktemp)
sed ':a;N;$!ba;s/\n/ /g;s/Common/\nCommon/g' $file > "$temp_file3"
mv "$temp_file3" "$file"

while read line; do
    expiration_date=$(echo $line | awk '{print $3}')
    cert_name=$(echo $line | awk '{print $1}')
    cert_name=$(echo $cert_name | sed 's/Common\///g')

    # Parse the expiration date into seconds since the epoch
    expiration_seconds=$(date +%s -d "@${expiration_date}" 2>/dev/null)

    # Calculate the number of seconds until the certificate expires
    seconds_until_expiry=$((expiration_seconds - $(date +%s)))

    # Calculate the number of days until the certificate expires
    days_until_expiry=$((seconds_until_expiry / 86400))

    # Check if the number of days until expiry is less than the threshold
    if ([ $days_until_expiry -lt $DAYS_THRESHOLD ] && [ $seconds_until_expiry -gt 0 ]); then
      echo "The certificate: $cert_name is expiring in $days_until_expiry" days >> will_exp.txt
    fi
done < "$file"

# Srot the file by the days
ddays=($(grep -oP '\d+ days' will_exp.txt | cut -d' ' -f1))

# Read each line of the file into an array
while read -r line; do
  lines+=("$line")
done < will_exp.txt

# Associate the days with their corresponding lines
for i in "${!days[@]}"; do
  printf "%s\t%s\n" "${days[$i]}" "${lines[$i]}" 
done |
# Sort the lines based on the number of days until expiration
sort -n -k1 |
# Remove the prefix from each line
cut -f2- > sorted.txt

mv sorted.txt will_exp.txt

# Call to the script that will send the email
./send_mail_with_attachment.sh
