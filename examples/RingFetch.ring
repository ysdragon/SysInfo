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
// Get Shell
shell = sys.shell()
// Get OS
os = sys.os()
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
// Get GPU name
gpu = sys.gpu()
// Get RAM size
ramSize = sys.ram()[:size]
// Get RAM used
ramUsed = sys.ram()[:used]
// Get RAM free
ramFree = sys.ram()[:free]
// Get System Uptime
uptime = sys.sysUptime()
// Get Packages count for Unix-like OSes or Program Count for Windows
pcount = sys.pCount()
// Get currently mounted storage parts
// Storage parts has (name, size, used, free)
parts = sys.storageParts()
// Get storage disks
// Storage disks has (name, size)
disks = sys.storageDisks()

print("
    **                     RingFetch                     **
    ** Author: ysdragon (https://github.com/ysdragon)    **

    Hostname: #{hostname}
    Username: #{username}
    Shell: #{shell}
    OS: #{os}
    Arch: #{arch}
    Kernel: #{version}
    Packages: #{pcount}
    CPU: #{cpuName} Cores: #{cpuCores} Threads: #{cpuThreads}
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
