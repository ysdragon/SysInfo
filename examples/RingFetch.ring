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
shellName = sys.shell()[:name] // ---> Get shell name
shellVersion = sys.shell()[:version] // ---> Get shell version
*/
shell = sys.shell()[:name] + " " + sys.shell()[:version]
/* Get currently running terminal (For Unix-like OSes only)
term = sys.term()
*/
/* Get OS info
Examples:
osName = sys.os()[:name] // ---> Get OS name
osID = sys.os()[:id] // ---> Get OS id
*/
osName = sys.os()[:name]
// Get System Architecture
arch = sys.arch()
// Get Kernel Version
version = sys.version()
// Get CPU name
cpuName = sys.cpu()[:name]
// Get CPU cores
cpuCores = sys.cpu()[:cores]
// Get CPU threads
cpuThreads = sys.cpu()[:threads]
// Get CPU usage
cpuUsage = string(sys.cpu()[:usage]) + "%"
// Get CPU temp (Currently for Unix-like OSes only)
if(isUnix()) {
    cpuTemp = ", Temp " + sys.cpu()[:temp] + "°"
else
    cpuTemp = NULL
}
// Get GPU name
gpu = sys.gpu()
// Get RAM size
ramSize = sys.ram()[:size]
// Get RAM used
ramUsed = sys.ram()[:used]
// Get RAM free
ramFree = sys.ram()[:free]
/*  Get System Uptime
Examples:
uptime = sys.sysUptime([]) // ---> (% days, % hours, % minutes, % seconds)
uptime = sys.sysUptime([:days = 1, :hours = 1, :minutes = 1, :seconds = 1]) //  ---> (% days, % hours, % minutes, % seconds)
uptime = sys.sysUptime([:days = 1, :hours = 1, :minutes = 1]) // ---> (% days, % hours, % minutes)
uptime = sys.sysUptime([:days = 1, :hours = 1]) // ---> (% days, % hours)
uptime = sys.sysUptime([:days = 1, :minutes = 1]) // ---> (% days, % minutes)
uptime = sys.sysUptime([:days = 1]) // ---> (% days)
uptime = sys.sysUptime([:minutes = 1]) // ---> (% minutes)
uptime = sys.sysUptime([:hours = 1]) // ---> (% hours)
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
    CPU: #{cpuName} Cores: #{cpuCores}, Threads: #{cpuThreads}, Usage: #{cpuUsage}#{cpuTemp}
    GPU: #{gpu}
    RAM: Size: #{ramSize}, Used: #{ramUsed}, Free: #{ramFree}
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
