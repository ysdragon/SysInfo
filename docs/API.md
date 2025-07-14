# SysInfo Package Documentation

## Usage

```ring
// Load the SysInfo package
load "SysInfo.ring"

// Create a new SysInfo instance
sys = new SysInfo

// Get basic system information
? "OS: " + sys.os()[:name]
? "Hostname: " + sys.hostname()
? "CPU: " + sys.cpu([])[:model]
? "Total RAM: " + (sys.ram()[:size] / 1024 / 1024) + " GB" // Note: RAM size is in KB
```

For more examples and detailed usage instructions, see the [Usage Guide](./Usage.md).

## API Reference

The `SysInfo` class provides the following public methods:

### `model()`
Retrieves the device model.
- **Returns**: `String` - The device model (e.g., "Surface Pro 11").

### `hostname()`
Retrieves the system's hostname.
- **Returns**: `String` - The hostname.

### `username()`
Retrieves the current logged-in user's name.
- **Returns**: `String` - The username.

### `os()`
Retrieves operating system information.
- **Returns**: `List` - A list containing:
    - `:name` (String): The pretty name of the OS (e.g., "Ubuntu 25.04").
    - `:id` (String): The OS identifier (e.g., "ubuntu", "windows").

### `version()`
Retrieves the kernel version of the operating system.
- **Returns**: `String` - The kernel version.

### `cpu(params)`
Retrieves detailed CPU information.
- **Args**: `params` (List) - An optional list to specify additional information to retrieve.
    - Example: `[:usage = 1]` to include CPU usage and temperature.
- **Returns**: `List` - A list containing:
    - `:count` (Number): Number of physical CPUs.
    - `:model` (String): CPU model name.
    - `:cores` (String): Total number of cores.
    - `:threads` (String): Total number of threads.
    - `:usage` (Number/Null): CPU usage percentage (Null if not available or `[:usage = 1]` was not passed).
    - `:temp` (Number/Null): CPU temperature in Celsius (Null if not available, on VMs for some OSes, or `[:usage = 1]` was not passed).
    - `:cpus` (List of Lists): Detailed information for each CPU (if available). Each sub-list contains:
        - `:number` (Number): CPU identifier.
        - `:model` (String): Model name for this CPU.
        - `:cores` (String): Cores for this CPU.
        - `:threads` (String): Threads for this CPU.

### `gpu()`
Retrieves GPU information.
- **Returns**: `String` - Name(s) of the GPU(s) or "No GPU detected!" or "Please install pciutils" (on Linux/FreeBSD if `lspci` is missing).

### `shell()`
Retrieves information about the current shell.
- **Returns**: `List` - A list containing:
    - `:name` (String): Name of the shell (e.g., "bash", "powershell").
    - `:version` (String): Version of the shell.

### `term()`
Retrieves information about the current terminal emulator (Unix-like OSes only).
- **Returns**: `String` - Terminal name and version (e.g., "xterm-256color") or "Unknown".

### `ram()`
Retrieves RAM and Swap/Pagefile information. Values are in KB.
- **Returns**: `List` - A list containing:
    - `:size` (Number): Total physical RAM.
    - `:used` (Number): Used physical RAM.
    - `:free` (Number): Free physical RAM.
    - `:swap` (Number): Total Swap/Pagefile space.

### `storageDisks()`
Retrieves information about physical storage disks.
- **Returns**: `List` of Lists - Each sub-list represents a disk and contains:
    - `:name` (String): Disk model or name.
    - `:size` (String): Disk size in KB.

### `storageParts()`
Retrieves information about storage partitions/logical disks.
- **Returns**: `List` of Lists - Each sub-list represents a partition and contains:
    - `:name` (String): Partition name.
    - `:size` (String): Partition size in KB.
    - `:used` (String): Used space on the partition in KB.
    - `:free` (String): Free space on the partition in KB.

### `sysUptime(params)`
Calculates and formats the system uptime.
- **Args**: `params` (List) - An optional list to specify which time units to include.
    - Example: `[:days = 1, :hours = 1, :minutes = 1, :seconds = 1]` (default if empty list or no param passed)
    - To show only days and hours: `[:days = 1, :hours = 1]`
- **Returns**: `String` - Formatted uptime string (e.g., "1 day, 2 hours, 30 minutes, 15 seconds").

### `arch()`
Retrieves the system architecture.
- **Returns**: `String` - System architecture (e.g., "amd64").

### `pCount()`
Retrieves the count of installed packages (Linux/FreeBSD) or programs via Winget (Windows).
- **Returns**: `String` - Package/program count, often with the package manager name (e.g., "1500 (dpkg)").

### `isVM()`
Checks if the system is likely a virtual machine.
- **Returns**: `Number` - `1` if a VM is detected, `0` otherwise.

### `network()`
Retrieves network interface information.
- **Returns**: `List` of Lists - Each sub-list represents a network interface and contains:
    - `:name` (String): Interface name/description.
    - `:ip` (String): IP address of the interface.
    - `:status` (String, optional): Status of the interface (e.g., "up").