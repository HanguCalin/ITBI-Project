#!/bin/bash

# Configuration file with mountpoints and lifetime in seconds
CONFIG_FILE="/home/vboxuser/Desktop/AMShell/amsh_mounts.conf" # Change this to the path of your configuration file
MOUNT_TIMEOUT=10  # Time reduced to 10 seconds for testing purposes(Usually it's 300 seconds)

RED="\033[0;31m"
RESET="\033[0m"

# Association for mountpoint timeouts
declare -A MOUNT_TIMERS

# Function to read configuration and check mountpoints
check_and_mount() {
    local TARGET_DIR="$1"
    while IFS= read -r line; do
        # Ignoră liniile care încep cu # (comentarii) sau sunt goale
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        
        DEVICE_PATH=$(echo "$line" | awk '{print $1}')
        MOUNTPOINT=$(echo "$line" | awk '{print $2}')
        FS_TYPE=$(echo "$line" | awk '{print $3}')
        
        if [[ $TARGET_DIR == $MOUNTPOINT* ]]; then
            if ! mount | grep -q "$MOUNTPOINT"; then
                echo "Mounting $MOUNTPOINT..."
                sudo mount -o loop "$DEVICE_PATH" "$MOUNTPOINT"
                sudo chown $(id -u):$(id -g) "$MOUNTPOINT"
                MOUNT_TIMERS["$MOUNTPOINT"]=$(date +%s)
            fi
            break
        fi
    done < "$CONFIG_FILE"
}


# Function to change directory(CD command)
change_directory() {
    local TARGET_DIR="$1"
    check_and_mount "$TARGET_DIR"

    if cd "$TARGET_DIR" 2>/dev/null; then
        echo "Changed directory to $TARGET_DIR"
    else
        echo "amsh: cd: $TARGET_DIR: No such file or directory"
    fi
}

# Function to check and uninstall inactive mountpoints
check_and_unmount() {
    for MP in "${!MOUNT_TIMERS[@]}"; do
        LAST_MOUNT=${MOUNT_TIMERS[$MP]}
        CURRENT_TIME=$(date +%s)
        if (( CURRENT_TIME - LAST_MOUNT >= MOUNT_TIMEOUT )); then
            echo "Checking for processes using $MP..."
            # Checks for active processes on the mountpoint, excluding the current shell
            ACTIVE_PROCESSES=$(lsof +D "$MP" 2>/dev/null | grep -v "$(basename "$0")")
            if [[ -z "$ACTIVE_PROCESSES" ]] && [[ "$PWD" != "$MP"* ]]; then
                echo "Unmounting $MP..."
                sudo umount "$MP"
                unset MOUNT_TIMERS["$MP"]
            else
                echo "$MP is still in use or current shell is in use. Skipping unmount."
            fi
        fi
    done
}

# Function to execute external commands, while checking for any mountpoints
execute_command() {
    local command="$1"
    local args="$2"

    # Checks if command parameters traverse a mountpoint
    if [[ -n "$args" ]]; then
        for arg in $args; do
	     dir=$(dirname "$arg")
            if [[ -d "$arg" ]]; then
                check_and_mount "$arg"
            fi
        done
    fi

    # Run the command after the mountpoints have been managed
    sh -c "$command $args"
}

# Main loop of the shell(The prompt)
start_shell() {
    while true; do
       	echo -ne "${RED}amsh> ${RESET}"
        read -r command args

        if [[ $command == "cd" ]]; then
            change_directory "$args"
        elif [[ $command == "exit" ]]; then
            echo "Exiting amsh..."
            sleep 2.25
            echo "Goodbye! See you next time!"
            break
        else
            execute_command "$command" "$args"
        fi

        check_and_unmount
    done
}

# Start the shell
start_shell
