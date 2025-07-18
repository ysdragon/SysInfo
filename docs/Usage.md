# Using the SysInfo Package

```ring
// Load the SysInfo package
load "SysInfo.ring"

// Create a new SysInfo instance
sys = new SysInfo
```

Now, you can use the `sys` object to call various methods to fetch system information.

## Fetching Basic Information

Here's how to get some of the most common system details:

```ring
// Get Device Model
model = sys.model()
? "Device Model: " + model

// Get OS Information
osDetails = sys.os()
osName = osDetails[:name]  // e.g., "Void Linux"
osID = osDetails[:id]      // e.g., "void"
? "Operating System: " + osName + " (ID: " + osID + ")"

// Get Hostname
hostname = sys.hostname()
? "Hostname: " + hostname

// Get Username
username = sys.username()
? "Username: " + username

// Get Kernel Version
kernelVersion = sys.version()
? "Kernel Version: " + kernelVersion

// Get System Architecture
architecture = sys.arch()
? "Architecture: " + architecture
```

## Working with CPU Information

The `cpu()` method returns a list with detailed CPU data.

```ring
// Get basic CPU information
cpuInfoBasic = sys.cpu([]) // Pass an empty list to get basic CPU info
? "CPU Model (Basic): " + cpuInfoBasic[:model]
? "Physical CPU Count: " + cpuInfoBasic[:count]
? "Total Cores: " + cpuInfoBasic[:cores]
? "Total Threads: " + cpuInfoBasic[:threads]

// Get CPU information including usage and temperature
cpuInfoFull = sys.cpu([:usage = 1]) // Pass [:usage = 1] to get usage and temp

if (!isNull(cpuInfoFull[:usage])) {
    ? "CPU Usage: " + cpuInfoFull[:usage] + "%"
}

if (!isNull(cpuInfoFull[:temp])) {
    ? "CPU Temperature: " + cpuInfoFull[:temp] + "°C"
}

// For multi-CPU systems, you can iterate through individual CPU details:
if (isList(cpuInfoFull[:cpus]) && len(cpuInfoFull[:cpus]) > 0 && cpuInfoFull[:count] > 1) {
    ? "Individual CPU Details:"
    for singleCpu in cpuInfoFull[:cpus] {
        ? "  CPU " + singleCpu[:number] + ": " + singleCpu[:model] + ", Cores: " + singleCpu[:cores] + ", Threads: " + singleCpu[:threads]
    }
}
```

## Retrieving GPU Information

```ring
gpuName = sys.gpu()
? "GPU: " + gpuName
```

## Checking Shell and Terminal

```ring
// Get Shell Information
shellDetails = sys.shell()
shellName = shellDetails[:name]
shellVersion = shellDetails[:version]
? "Shell: " + shellName + " " + shellVersion

// Get Terminal Information (Unix-like OSes)
if isUnix() {
    terminalInfo = sys.term()
    ? "Terminal: " + terminalInfo
}
```

## Accessing RAM and Swap/Pagefile Details

RAM and Swap values are returned in KB.

```ring
ramInfo = sys.ram()

? "Total RAM: " + (ramInfo[:size] / 1024 / 1024) + " GB"
? "Used RAM: " + (ramInfo[:used] / 1024 / 1024) + " GB"
? "Free RAM: " + (ramInfo[:free] / 1024 / 1024) + " GB"
? "Swap/Pagefile Total: " + (ramInfo[:swap] / 1024 / 1024) + " GB"
```

## Listing Storage Devices

### Physical Disks

```ring
storageDisks = sys.storageDisks()
? "Storage Disks:"
if (isList(storageDisks) && len(storageDisks) > 0) {
    for disk in storageDisks {
        ? "  Name: " + disk[:name] + ", Size: " + (disk[:size] / 1024 / 1024) + " GB"
    }
else
    ? "  No physical disks detected or information unavailable."
}
```

### Partitions / Logical Disks

```ring
storageParts = sys.storageParts()
? "Storage Partitions:"
if (isList(storageParts) && len(storageParts) > 0) {
    for part in storageParts {
        ? "  Name/Mount: " + part[:name] + ", Size: " + (part[:size] / 1024 / 1024) + " GB" + ", Used: " + (part[:used] / 1024 / 1024) + " GB" + ", Free: " + (part[:free] / 1024 / 1024) + " GB"
    }
else
    ? "  No storage partitions detected or information unavailable."
}
```

## Getting System Uptime

The `sysUptime()` method allows customization of the output format.

```ring
// Default: shows days, hours, minutes, seconds
uptimeDefault = sys.sysUptime([])
? "Uptime (Default): " + uptimeDefault

// Custom: show only days and hours
uptimeCustom = sys.sysUptime([:days = 1, :hours = 1])
? "Uptime (Days & Hours): " + uptimeCustom

// Custom: show only minutes and seconds
uptimeMinutesSeconds = sys.sysUptime([:minutes = 1, :seconds = 1])
? "Uptime (Minutes & Seconds): " + uptimeMinutesSeconds
```


## Package Manager Information

```ring
packageManagerInfo = sys.packageManager()
? "Package Manager Name: " + packageManagerInfo[:name]
? "Installed Package Count: " + packageManagerInfo[:count]
```

## Virtual Machine Detection

```ring
isVirtualMachine = sys.isVM()
if (isVirtualMachine) {
    ? "System is running on a Virtual Machine."
else
    ? "System is not running on a Virtual Machine."
}
```

## Network Interface Information

```ring
networkInterfaces = sys.network()
? "Network Interfaces:"
if (isList(networkInterfaces) && len(networkInterfaces) > 0) {
    for iface in networkInterfaces {
        line = "  " + iface[:name] + " - IP: " + iface[:ip]
        if (!isNull(iface[:status])) {
            line = line + ", Status: " + iface[:status]
        }
        ? line
    }
else
    ? "  No network interfaces detected or information unavailable."
}
```

This guide covers the primary functionalities of the SysInfo package. For a complete list of methods and their detailed return values, please refer to the [API Reference in API.md](./API.md).
