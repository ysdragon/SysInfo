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
cpuInfo = sys.cpu()

? "CPU Model: " + cpuInfo[:model]
? "Physical CPU Count: " + cpuInfo[:count]
? "Total Cores: " + cpuInfo[:cores]
? "Total Threads: " + cpuInfo[:threads]

if !isNull(cpuInfo[:usage]) {
    ? "CPU Usage: " + cpuInfo[:usage] + "%"
}

if !isNull(cpuInfo[:temp]) {
    ? "CPU Temperature: " + cpuInfo[:temp] + "°C"
}

// For multi-CPU systems, you can iterate through individual CPU details:
if isList(cpuInfo[:cpus]) and len(cpuInfo[:cpus]) > 0 and cpuInfo[:count] > 1 {
    ? "Individual CPU Details:"
    for singleCpu in cpuInfo[:cpus] {
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

RAM and Swap values are returned in MB.

```ring
ramInfo = sys.ram()

? "Total RAM: " + ramInfo[:size] + " MB"
? "Used RAM: " + ramInfo[:used] + " MB"
? "Free RAM: " + ramInfo[:free] + " MB"
? "Swap/Pagefile Total: " + ramInfo[:swap] + " MB"
```

## Listing Storage Devices

### Physical Disks

```ring
storageDisks = sys.storageDisks()
? "Storage Disks:"
if isList(storageDisks) and len(storageDisks) > 0 {
    for disk in storageDisks {
        ? "  Name: " + disk[:name] + ", Size: " + disk[:size]
    }
else
    ? "  No physical disks detected or information unavailable."
}
```

### Partitions / Logical Disks

```ring
storageParts = sys.storageParts()
? "Storage Partitions:"
if isList(storageParts) and len(storageParts) > 0 {
    for part in storageParts {
        ? "  Name/Mount: " + part[:name] + ", Size: " + part[:size] + ", Used: " + part[:used] + ", Free: " + part[:free]
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

## Package Count

```ring
packageCount = sys.pCount()
? "Installed Packages/Programs: " + packageCount
```

## Virtual Machine Detection

```ring
isVirtualMachine = sys.isVM()
if isVirtualMachine {
    ? "System is running on a Virtual Machine."
else
    ? "System is not running on a Virtual Machine."
}
```

## Network Interface Information

```ring
networkInterfaces = sys.network()
? "Network Interfaces:"
if isList(networkInterfaces) and len(networkInterfaces) > 0 {
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
