/*
    RingFetch - A system information display tool
    Author: ysdragon (https://github.com/ysdragon)
    
    This example demonstrates how to use the SysInfo package to gather
    and display comprehensive system information in a formatted output.
*/

// Load the SysInfo package
load "SysInfo.ring"

// Initialize the SysInfo class to access system information methods
sys = new SysInfo

// ===========================================
// BASIC SYSTEM IDENTIFICATION
// ===========================================

// Retrieve system hostname (computer name on network)
hostname = sys.hostname()

// Get current logged-in username
username = sys.username()

// Get shell information (name and version)
// Example usage for individual components:
//   shellName = sys.shell()[:name]     // Shell name only
//   shellVersion = sys.shell()[:version] // Shell version only
shell = sys.shell()[:name] + " " + sys.shell()[:version]

// Get terminal emulator information (Unix-like systems only)
// Uncomment the line below if you need terminal detection
// term = sys.term()

// ===========================================
// OPERATING SYSTEM INFORMATION
// ===========================================

// Get operating system name
// Alternative: sys.os()[:id] for OS identifier
osName = sys.os()[:name]

// Get system architecture (e.g., x86_64, arm64)
arch = sys.arch()

// Get kernel version information
version = sys.version()

// ===========================================
// CPU INFORMATION AND PERFORMANCE
// ===========================================

// CPU information retrieval with multiple available fields:
//   count   - Number of physical CPUs
//   model   - CPU model name
//   cores   - Total number of cores
//   threads - Total number of logical processors/threads
//   usage   - Current CPU usage percentage
//   temp    - CPU temperature (Unix-like systems, non-VM only)

// Get number of physical CPU packages
cpuCount = sys.cpu()[:count]

// Format CPU model display based on CPU count
if (cpuCount > 1) {
    // Multiple CPUs: show count prefix (e.g., "2x Intel Core i7...")
    cpuModel = string(cpuCount) + "x " + sys.cpu()[:model]
else
    // Single CPU: show model name only
    cpuModel = sys.cpu()[:model]
}

// Get CPU specifications
cpuCores = sys.cpu()[:cores]     // Total number of cores
cpuThreads = sys.cpu()[:threads] // Total number of logical processors
cpuUsage = string(sys.cpu()[:usage]) + "%" // Current usage percentage

// Get CPU temperature (available on Unix-like systems, non-VM environments)
if(isUnix() && !sys.isVM()) {
    cpuTemp = ", Temp " + sys.cpu()[:temp] + "°"
else
    cpuTemp = NULL // Temperature not available on Windows or VMs
}

// ===========================================
// GRAPHICS HARDWARE
// ===========================================

// Get primary graphics card information
gpu = sys.gpu()

// ===========================================
// MEMORY INFORMATION
// ===========================================

// Retrieve memory statistics (all values in MB for RAM)
totalRam = sys.ram()[:size]  // Total installed RAM
usedRam = sys.ram()[:used]   // Currently used RAM
freeRam = sys.ram()[:free]   // Available free RAM

// Handle swap/pagefile information based on operating system
swapRam = NULL
if (isWindows()) {
    // Windows uses pagefile for virtual memory
    swapRam = "Pagefile: " + sys.ram()[:swap]
elseif (isUnix())
    // Unix-like systems use swap partitions/files
    swapRam = "Swap: " + sys.ram()[:swap]
}

// ===========================================
// SYSTEM UPTIME
// ===========================================

// Get system uptime with flexible formatting options:
// Examples of different uptime formats:
//   [] - Auto format (days, hours, minutes, seconds as needed)
//   [:days = 1, :hours = 1, :minutes = 1, :seconds = 1] - Full format
//   [:days = 1, :hours = 1] - Days and hours only
//   [:minutes = 1] - Minutes only
uptime = sys.sysUptime([]) // Auto-format based on uptime duration

// ===========================================
// SOFTWARE PACKAGES
// ===========================================

// Get installed package/program count
// Unix-like: packages from package manager
// Windows: installed programs from registry
pcount = sys.pCount()

// ===========================================
// STORAGE INFORMATION
// ===========================================

// Get physical storage devices information
// Each disk contains: name (model) and size (in bytes)
disks = sys.storageDisks()

// Check if system is running in a virtual machine
// Useful for conditional feature availability
// isVM = sys.isVM() // Returns true for VMs, false for physical machines

// ===========================================
// DISPLAY SYSTEM INFORMATION
// ===========================================

print("
    **                     RingFetch                     **
    **   Author: ysdragon (https://github.com/ysdragon)  **

    Hostname: #{hostname}
    Username: #{username}
    Shell: #{shell}
    OS: #{osName}
    Arch: #{arch}
    Kernel: #{version}
    Packages: #{pcount}
    CPU: #{cpuModel} Cores: #{cpuCores}, Threads: #{cpuThreads}, Usage: #{cpuUsage}#{cpuTemp}
    GPU: #{gpu}
    RAM: Size: #{totalRam}, Used: #{usedRam}, Free: #{freeRam}, #{swapRam}
    Uptime: #{uptime}
")

// Display physical storage devices
print("    Storage Disks: \n")
for disk in disks {
    diskName = disk[:name]  // Device model/name
    diskSize = disk[:size]  // Device capacity
    print("             #{diskName} Size: #{diskSize}\n")
}

// ===========================================
// MOUNTED STORAGE PARTITIONS
// ===========================================

// Get currently mounted storage partitions/volumes
// Each partition contains: name, size, used space, free space
storageParts = sys.storageParts()
print("    Storage Parts: \n")
if (isList(storageParts) and len(storageParts) > 0) {
    for part in storageParts {
        if (isList(part)) {
            partName = part[:name]  // Mount point or drive letter
            partSize = part[:size]  // Total partition size
            partUsed = part[:used]  // Used space
            partFree = part[:free]  // Available free space
            print("             #{partName} Size: #{partSize}, Used: #{partUsed}, Free: #{partFree}\n")
        }
    }
else
    print("             No storage parts detected\n")
}

// ===========================================
// NETWORK INTERFACES
// ===========================================

// Get active network interface information
// Each interface contains: name, IP address, status
networkInfo = sys.network()
print("    Network Interfaces: \n")
if (isList(networkInfo) and len(networkInfo) > 0) {
    for interface in networkInfo {
        if (isList(interface)) {
            interfaceName = interface[:name]      // Interface description/name
            interfaceIP = interface[:ip]          // Assigned IP address
            interfaceStatus = interface[:status]  // Connection status
            print("             #{interfaceName} - IP: #{interfaceIP}, Status: #{interfaceStatus}\n")
        }
    }
else
    print("             No network interfaces detected\n")
}
