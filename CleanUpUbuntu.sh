#!/bin/bash

# A bash script to clean up your Ubuntu system.

echo "Starting system cleanup process..."

# Function to check for root privileges
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Please run this script as root or use sudo."
        exit 1
    fi
}

# Update and upgrade packages
update_system() {
    echo "Updating package lists..."
    apt update -y
    echo "Upgrading installed packages..."
    apt upgrade -y
}

# Clean up unnecessary packages and files
clean_system() {
    echo "Removing unused packages and dependencies..."
    apt autoremove -y
    apt autoclean -y
    echo "Clearing APT cache..."
    apt clean
}

# Remove orphaned packages
remove_orphans() {
    echo "Removing orphaned packages..."
    apt-get remove --purge -y $(deborphan)
}

# Clear user-level cache
clear_user_cache() {
    echo "Clearing user cache..."
    rm -rf ~/.cache/*
}

# Free up system disk space
free_disk_space() {
    echo "Clearing system journal logs (keeping last 7 days)..."
    journalctl --vacuum-time=7d
    echo "Cleaning up old kernels..."
    dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-[0-9]+' | grep -v "$(uname -r)" | xargs sudo apt -y purge
}

# Optimize snap package usage
clean_snap() {
    echo "Removing old Snap revisions..."
    snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
}


## Optimize
#################

# Enable performance governor for the CPU
optimize_cpu() {
    echo "Setting CPU governor to performance mode..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$cpu" 2>/dev/null || true
    done
}

# Optimize swappiness value
optimize_swappiness() {
    echo "Optimizing swappiness to improve system performance..."
    sysctl vm.swappiness=10
    echo "vm.swappiness=10" >> /etc/sysctl.conf
}

# Clear RAM cache
clear_ram_cache() {
    echo "Clearing RAM cache..."
    sync && echo 3 > /proc/sys/vm/drop_caches
}

# Optimize I/O performance
optimize_io() {
    echo "Enabling I/O scheduler optimization..."
    echo noop > /sys/block/sda/queue/scheduler
}

# Display disk usage
display_disk_usage() {
    echo "Disk usage after cleanup:"
    df -h
}

# Display free memory and disk usage
display_usage() {
    echo "Displaying memory and disk usage..."
    free -h
    df -h
}

# Main execution
main() {
    check_root
    update_system
    clean_system
    remove_orphans
    clear_user_cache
    free_disk_space
    clean_snap
    optimize_cpu
    optimize_swappiness
    clear_ram_cache
    optimize_io
    display_disk_usage
    display_usage
    echo "System cleanup complete!"
}

main
