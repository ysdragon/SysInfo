/*
    Author: ysdragon (https://github.com/ysdragon)
*/

load "stdlibcore.ring"
load "jsonlib.ring"
load "constants.ring"

class SysInfo {
    
    // Check if the Operating System is Windows
    if(isWindows()) {
        // Create a temporary PowerShell script file in the %TEMP% directory
        psTempScript = tempname() + ".ps1"
        // Open the file for writing
        fp = fopen(psTempScript, "w")
        // Write the content of PS_SCRIPT to the temp PowerShell file
        fwrite(fp, PS_SCRIPT)
        // Close the file stream
        fclose(fp)
        // Execute the temp PowerShell script
        cmd = SystemCmd("powershell -NoProfile -ExecutionPolicy Bypass -File " + psTempScript)
        // Convert the returned JSON to a list
        winSysInfo = json2List(cmd)
        // Delete the temp PowerShell script
        OSDeleteFile(psTempScript)
    }

    // Function to get the hostname
    func hostname() {
        // Check if the Operating System is Windows
        if(isWindows()) {
            // Execute command to get hostname
            hostname = SystemCmd("hostname")
            
            // Return hostname
            return hostname
        else // Else (If the OS is (Unix-like))
            // Execute command to get hostname
            hostname = SystemCmd("cat /proc/sys/kernel/hostname")

            // Return hostname
            return hostname
        }
    }

    // Function to get the username
    func username() {
        // Check if the OS is Windows
        if (isWindows()) {
            // Get the USERNAME environment variable
            return sysget("USERNAME")
        else // Else (If the OS is (Unix-like))
            // Get the USER environment variable
            return sysget("USER")
        }
    }

    // Function to get OS name
    func os() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get os from winSysInfo List
            osName = winSysInfo[:os]    

            // Return os name         
            return osName
        else // Else (If the OS is (Unix-like))
            // Execute command to get OS name
            osInfo = SystemCmd("cat /etc/os-release | grep ^PRETTY_NAME=")
            // Split the returned text from osInfo
            osName = split(osInfo, "=")
            // Get OS name without double-quotes
            osName = substr(osName[2], '"', "")

            // Return the OS name
            return osName
        }
    }

    // Function to get the Kernel version
    func version() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get Windows NT Kernel version from winSysInfo
            kVersion = winSysInfo[:version]

            // Return Windows NT Kernel version
            return kVersion
        else // Else (If the OS is (Unix-like))
            // Execute command to get Kernel from Unix-Like OSes
            kVersion = SystemCmd("uname -r")

            // Return Kernel
            return kVersion
        }
    }

    // Function to get CPU Name, Cores and Threads
    func cpu() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get CPU info from winSysInfo list
            cpuInfo = winSysInfo[:cpu]

            // Return CPU info
            return cpuInfo
        else // Else (If the OS is (Unix-like))
            // Execute command to get CPU info
            cpuInfo = SystemCmd("cat /proc/cpuinfo")
            // Split cpuInfo into lines
            cpuInfo = split(cpuInfo, "\n")

            // Split to get CPU name
            cpuName = split(cpuInfo[5], ":")
            // Get CPU Name
            cpuName = cpuName[2]
            // Trim all left spaces
            cpuName = trimLeft(cpuName)

            // Split to get CPU cores
            cpuCores = split(cpuInfo[13], ":")
            // Get CPU cores
            cpuCores = cpuCores[2]
            // Trim all left spaces
            cpuCores = trimLeft(cpuCores)
            
            // Execute command to get CPU threads
            cpuThreads = SystemCmd("cat /proc/cpuinfo | grep -c '^processor'")

            // Initialize cpuInfo list
            cpuInfo = []

            // Add name to cpuInfo
            cpuInfo[:name] = cpuName
            // Add cores to cpuInfo
            cpuInfo[:cores] = cpuCores
            // Add threads to cpuInfo
            cpuInfo[:threads] = cpuThreads
            
            // Return cpuInfo
            return cpuInfo
        }
    }

    // Function to get GPU name
    func gpu() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get GPU info from winSysInfo list
            gpuInfo = winSysInfo[:gpu]

            // Initialize gpuName
            gpuName = ""

            // Check if the length of gpuInfo greater than 1
            if(len(gpuInfo) > 1) {
                // Loop in every GPU
                for i=1 to len(gpuInfo) {
                    gpuName += "GPU" + i + ": " + gpuInfo[i][:name] + " "
                }
            elseif(len(gpuInfo) = 1) // If there's only one GPU return its model name
                gpuName = gpuInfo[1][:name]
            else  // If there's no GPU detected
                gpuName = "No GPU detected!"
            }

            // Return GPU name
            return gpuName
        else // Else (If the OS is (Unix-like))
            try {
                // Check if pciutils is installed
                result = SystemCmd("which lspci")
                if isNull(result) {
                    return "Please install pciutils"
                }

                // Execute command to get GPU name
                gpuInfo = SystemCmd("lspci -d *::0300 -mm")

                // Check if no GPU detected
                if isNull(gpuInfo) {
                    return "No GPU detected"
                }

                // Split the output by "
                gpuName = split(gpuInfo, '" ')
                // Remove any double-quotes
                gpuName = substr(gpuName[3], '"', "")

                // Return GPU name
                return  gpuName
            catch // If an error occurred
                return "An error occurred while fetching GPU information"
            }
        }
    }

    // Function to get currently running shell
    func shell() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get currently running shell name from winSysInfo
            shellName = winSysInfo[:shell]

            // Return Shell name
            return shellName
        else // Else (If the OS is (Unix-like))
            // Execute command to get currently running shell
            ShellInfo = SystemCmd("env | grep '^SHELL=' | cut -d= -f2")
            // Get shell name only from its path e.g. /usr/bin/fish --> fish
            shellName = JustFileName(ShellInfo)

            // Return Shell name
            return shellName
        }
        
    }
    
    func ram() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get Ram info (size, used, free) from winSysInfo
            ramInfo = winSysInfo[:ram]

            // Return Ram info
            return ramInfo
        else // Else (If the OS is (Unix-like))
            // Initialize ramInfo
            ramInfo = []
            
            // Execute command to get Ram info
            memInfo = SystemCmd("grep -E 'MemTotal|MemAvailable' /proc/meminfo")
            // Split memInfo into lines
            memInfo = split(memInfo, "\n")

            // Split to get total ram size
            totalRam = split(memInfo[1], ":")
            // Trim spaces
            totalRam = trim(totalRam[2])
            // Remove kB
            totalRam = substr(totalRam, "kB", "")
            // Convert from kB to GB
            totalRam = totalRam / 1024 / 1024

            // Split to get free ram
            freeRam = split(memInfo[2], ":")
            // Trim spaces
            freeRam = trim(freeRam[2])
            // Remove kB
            freeRam = substr(freeRam, "kB", "")
            // Convert from kB to GB
            freeRam = freeRam / 1024 / 1024
            
            // Add size to ramInfo
            ramInfo[:size] = totalRam
            // Calculate and add used to ramInfo
            ramInfo[:used] = totalRam - freeRam
            // Add free to ramInfo
            ramInfo[:free] = freeRam
            
            // Return Ram info
            return ramInfo
        }
    }

    // Function to get storage disks info
    func storageDisks() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get storage disks (name, size) from winSysInfo
            storageDisks = winSysInfo[:disks]

            // Return storage disks
            return storageDisks
        else // Else (If the OS is (Unix-like))
            // Get blockdevices from StorageInfo
            blockDevices = storageInfo()
            
            // Initialize StorageDisks
            storageDisks = []

            // Loop in every blockdevice in blockDevices
            for blockDevice in blockDevices {
                // Add blockDevice name and size to StorageDisks
                add(storageDisks, [:name = blockDevice[:name], :size = blockDevice[:size]])
            }
            
            // Return storageDisks
            return storageDisks
        }
    }

    // Function to get storage parts info
    func storageParts() {
        // Check if the OS is Windows
        if(isWindows()) {
            // Get storage parts from winSysInfo (name, size, used, free)
            storageParts = winSysInfo[:parts]

            // Return storageParts
            return storageParts
        else // Else (If the OS is (Unix-like))
            // Get blockdevices from StorageInfo
            blockDevices = storageInfo()
            
            // Initialize storageParts
            storageParts = []

            // Loop every blockDevice in blockDevices
            for blockDevice in blockDevices {
                // Loop every children in blockDevice (disk part)
                for children in blockDevice[:children] {
                    // Check if mountpoints is not null or empty
                    if (children[:mountpoints] != NULL and len(children[:mountpoints]) > 0) {
                        // Initialize isValidMountPoint
                        isValidMountPoint = false
                        
                        // Loop every mountpoint in children (disk part)
                        for mountpoint in children[:mountpoints] {
                            // Check if mountpoint value is not "null"
                            if (mountpoint != "null") {
                                isValidMountPoint = true
                                break
                            }
                        }

                        // Execute the command if a valid mountpoint was found
                        if (isValidMountPoint) {
                            try {
                                // Execute command to get specific children (part) (name, size, used, free)
                                childrenInfo = SystemCmd("df -h --output=source,size,used,avail | grep '" + children[:name] + "' | sed -E 's/[[:space:]]+/-/g; s/(.*):/\1:/' | sed 's/$/-/'")
                                // Split the output
                                childrenInfo = split(childrenInfo, "-")
                                
                                // Ensure we have enough list items
                                if (len(childrenInfo) = 4) {
                                    // Get childrenName (part name)
                                    childrenName = childrenInfo[1]
                                    // Get childrenSize (part size)
                                    childrenSize = childrenInfo[2]
                                    // Get childrenUsed (part used size)
                                    childrenUsed = childrenInfo[3]
                                    // Get childrenFree (part free size)
                                    childrenFree = childrenInfo[4]

                                    // Add children (part) to StorageParts
                                    add(storageParts, [:name = childrenName, :size = childrenSize, :used = childrenUsed, :free = childrenFree])
                                }
                            catch 
                                // Handle the error
                                ? "Error: " + cCatchError
                            }
                        }
                    }
                }
            }

            // Return storageParts
            return storageParts
        }
    }

    // Function to get uptime
    func sysUptime(params) {
        // Get calculated uptimeInfo
        fUptime = calcUptime(uptime(), params)

        // Return uptime
        return fUptime
    }

    // Function to get System Architecture
    func arch() {
        // Get System Architecture
        sysArch = GetArch()

        // Return System Architecture
        return sysArch
    }

    // Function to get Package/Program count
    func pCount() {
        // Check if the OS is Windows
        if(isWindows()) {
            pCount = winSysInfo[:pcount]

            return pCount
        else // Else (If the OS is (Unix-like))
            // Default pCount value
            pCount = "Unknown" // Unknown when your OS is not supported

            // Loop in every package manager
            for pManager in pManagers {
                // If your OS is supported get pCount
                if(find(pManager[2][:supported], osID())) {
                    pCount = SystemCmd(pManager[2][:cmd]) + " (" + pManager[2][:name] + ")"                    
                }
            }
        }

        // Return package count
        return pCount
    }

    // Function to calculate uptime based on uptimeInfo and the given params list
    func calcUptime(uptimeInfo, params) {
        // Set default parameter values if not provided, not a list, or the list is empty
        if !isList(params) or len(params) = 0 {
            params = [:days = 1, :hours = 1, :minutes = 1, :seconds = 1]
        }
        
        // Convert uptimeInfo from 0.1 ms to seconds
        totalSeconds = floor(uptimeInfo / 10000000)

        # Define time units
        tUnits = [
            [86400, "day", :days],
            [3600, "hour", :hours],
            [60, "minute", :minutes],
            [1, "second", :seconds]
        ]

        # Format the uptime string
        fUptime = ""
        for tUnit in tUnits {
            if params[tUnit[3]] = 1 {
                value = floor(totalSeconds / tUnit[1])
                if value > 0 or len(fUptime) > 0 {
                    if len(fUptime) > 0 {
                        fUptime += ", "
                    }
                    fUptime += string(value) + " " + tUnit[2]
                    if value != 1 {
                        fUptime += "s"
                    }
                    totalSeconds = totalSeconds % tUnit[1]
                }
            }
        }

        # Return uptime
        return fUptime
    }

    // Function to get Storage Info (For Unix-like OSes)
    func storageInfo() {
        // Execute command to get storage info
        storageInfo = SystemCmd("lsblk --json")
        // Convert json to list
        storageInfo = json2List(storageInfo)
        // Get blockdevices from StorageInfo
        blockDevices = storageInfo[:blockdevices]

        // Return blockDevices
        return blockDevices
    }

    // Function to get OS id (For Unix-like OS only)
    func osID() {
        // If the OS is not Windows (Unix-like)
        if(!isWindows()) { 
            // Execute command to get OS ID
            osInfo = SystemCmd("cat /etc/os-release | grep ^ID=")
            // Split the returned text from osInfo
            osId = split(osInfo, "=")
            // Get OS name without double-quotes
            osId = substr(osId[2], '"', "")

            // Return the OS ID
            return osId
        }
    }
}