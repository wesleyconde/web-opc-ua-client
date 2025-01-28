#!/bin/bash
set -e

# Temporary file for dialog output
TMP_FILE=$(mktemp)

# trap it
trap "rm -f $data" 0 1 2 5 15

# Cleanup function to remove temporary file
cleanup() {
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

# get password
password=$(dialog --title "Password" --stdout --clear --insecure --passwordbox "Enter the password" 10 30 )

if [ $password == "mctech" ]; then

  # Form for IP address and port input
  dialog --title "OPC Ua Client" --form "Enter the address and port below:" 15 50 2 \
    "IP Address:" 1 1 "127.0.0.1" 1 15 30 0 \
    "Port:"      2 1 "8080"      2 15 30 0 \
    2> "$TMP_FILE"

  # Check if the user canceled
  if [ $? -ne 0 ]; then
    echo "Operation canceled by the user."
    exit 1
  fi

  # Read the form values
  ADDRESS=$(sed -n 1p "$TMP_FILE")
  PORT=$(sed -n 2p "$TMP_FILE")
  # Cleanup and return to normal terminal
  clear

  opcua-commander -e opc.tcp://$ADDRESS:$PORT

else

  dialog --msgbox  "Incorrect password." 10 25

fi


