/*
    Author: ysdragon (https://github.com/ysdragon)
*/

// Load SysInfo Package
load "SysInfo.ring"

// Create a new instance of the SysInfo class to gather system information
sys = new SysInfo

// Get hostname
hostname = sys.hostname()
// Get username
username = sys.username()
/* Get Shell
 * shellName = sys.shell()[:name] // ---> Get shell name
 * shellVersion = sys.shell()[:version] // ---> Get shell version
 */
shell = sys.shell()[:name] + " " + sys.shell()[:version]
/* Get currently running terminal (For Unix-like OSes only)
term = sys.term()
*/

/* Get OS info
 * Examples:
 * osName = sys.os()[:name] // ---> Get OS name
 * osID = sys.os()[:id] // ---> Get OS id
 */
osName = sys.os()[:name]
// Get System Architecture
arch = sys.arch()
// Get Kernel Version
version = sys.version()

/* Get CPU Info
 * Examples:
 * cpuCount = sys.cpu()[:count] // ---> Get CPU count
 * cpuModel = sys.cpu()[:model] // ---> Get CPU model
 * cpuCores = sys.cpu()[:cores] // ---> Get CPU cores
 * cpuThreads = sys.cpu()[:threads] // ---> Get CPU threads
 * cpuUsage = sys.cpu()[:usage] // ---> Get CPU usage
 * cpuTemp = sys.cpu()[:temp] // ---> Get CPU temp (Currently for Unix-like OSes only)
 */

// Get CPU count
cpuCount = sys.cpu()[:count]

// Check if CPU count is greater than 1
if (cpuCount > 1) {
    // Get CPU model
    cpuModel = string(cpuCount) + "x " + sys.cpu()[:model]
else
    // Get CPU model
    cpuModel = sys.cpu()[:model]
}

// Get CPU cores
cpuCores = sys.cpu()[:cores]
// Get CPU threads
cpuThreads = sys.cpu()[:threads]
// Get CPU usage
cpuUsage = string(sys.cpu()[:usage]) + "%"
// Get CPU temp (Currently for Unix-like OSes only)
if(isUnix() && !sys.isVM()) {
    cpuTemp = ", Temp " + sys.cpu()[:temp] + "°"
else
    cpuTemp = NULL
}
// Get GPU name
gpu = sys.gpu()
// Get RAM size
totalRam = sys.ram()[:size]
// Get used RAM 
usedRam = sys.ram()[:used]
// Get free RAM 
freeRam = sys.ram()[:free]

// Initialize swapRam
swapRam = NULL
// Check if the OS is Windows
if (isWindows()) {
    // Get Pagefile size
    swapRam = "Pagefile: " + sys.ram()[:swap]
elseif (isUnix())
    // Get Swap size
    swapRam = "Swap: " + sys.ram()[:swap]
}

/*  Get System Uptime
 * Examples:
 * uptime = sys.sysUptime([]) // ---> (% days, % hours, % minutes, % seconds)
 * uptime = sys.sysUptime([:days = 1, :hours = 1, :minutes = 1, :seconds = 1]) //  ---> (% days, % hours, % minutes, % seconds)
 * uptime = sys.sysUptime([:days = 1, :hours = 1, :minutes = 1]) // ---> (% days, % hours, % minutes)
 * uptime = sys.sysUptime([:days = 1, :hours = 1]) // ---> (% days, % hours)
 * uptime = sys.sysUptime([:days = 1, :minutes = 1]) // ---> (% days, % minutes)
 * uptime = sys.sysUptime([:days = 1]) // ---> (% days)
 * uptime = sys.sysUptime([:minutes = 1]) // ---> (% minutes)
 * uptime = sys.sysUptime([:hours = 1]) // ---> (% hours)
*/
uptime = sys.sysUptime([])
// Get Packages count for Unix-like OSes or Program Count for Windows
pcount = sys.pCount()
// Get currently mounted storage parts
// Storage parts has (name, size, used, free)
parts = sys.storageParts()
// Get storage disks
// Storage disks has (name, size)
disks = sys.storageDisks()
/* Method to check if the machine is a VM
isVM = sys.isVM() // ---> true if it's a VM, false if it is not
*/

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

print("    Storage Disks: \n")
for disk in disks {
    diskName = disk[:name]
    diskSize = disk[:size]
    print("             #{diskName} Size: #{diskSize}\n")
}


print("    Storage Parts: \n")
for part in parts {
    partName = part[:name]
    partSize = part[:size]
    partUsed = part[:used]
    partFree = part[:free]
    print("             #{partName} Size: #{partSize}, Used: #{partUsed}, Free: #{partFree}\n")
}
