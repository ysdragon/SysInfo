/*
    Author: ysdragon (https://github.com/ysdragon)
*/

load "stdlibcore.ring"
load "jsonlib.ring"
load "constants.ring"

class SysInfo {
    
    // Check if the OS is Windows
    if (isWindows()) {
        // Setup temporary PowerShell script
        psTempScript = tempname() + ".ps1"

        // Write script content
        fp = fopen(psTempScript, "w")
        fwrite(fp, PS_SCRIPT)
        fclose(fp)

        // Execute PowerShell script with security bypass
        cmd = systemCmd("powershell -NoProfile -ExecutionPolicy Bypass -File " + psTempScript)

        // Process results 
        winSysInfo = json2List(cmd)

        // Cleanup
        OSDeleteFile(psTempScript)
    }

    // Method to get device model
    func model() {
        // Get model info from modelInfo
        modelInfo = modelInfo()

        // Return the model info
        return modelInfo
    }

    // Method to get the hostname
    func hostname() {
        // Execute command to get hostname
        hostname = systemCmd("hostname")
    
        // Return hostname
        return hostname
    }

    // Method to get the username
    func username() {
        // Check if the OS is Windows
        if (isWindows()) {
            // Get the USERNAME environment variable

            return SysGet("USERNAME")
        else // Else (If the OS is (Unix-like))
            if (!isNull(SysGet("USER"))) {
                return SysGet("USER")
            elseif (!isNull(SysGet("USERNAME")))
                return SysGet("USERNAME")
            else
                return systemCmd("whoami")
            }
        }
    }

    // Method to get OS name
    func os() {
        // Get osInfo
        osInfo = osInfo()

        // Return the OS info
        return osInfo
    }

    // Method to get the Kernel version
    func version() {
        // Get the Kernel version from kernelInfo
        kVersion = kernelInfo()

        // Return the Kernel version
        return kVersion
    }

    // Method to get CPU name, cores and threads
    func cpu() {
        // Get CPU info from cpuInfo
        cpuInfo = cpuInfo()          

        // Return cpuInfo
        return cpuInfo
    }

    // Method to get GPU name
    func gpu() {
        // Initialize gpuName
        gpuName = "Unknown"

        // Check if the OS is Windows
        if (isWindows()) {
            // Get GPU info from winSysInfo list
            gpuInfo = winSysInfo[:gpu]

            // Initialize the gpuName var
            gpuName = ""

            // Check if the length of gpuInfo greater than 1
            if (len(gpuInfo) > 1) {
                // Loop in every GPU
                for i=1 to len(gpuInfo) {
                    gpuName += "GPU" + i + ": " + gpuInfo[i][:name] + " "
                }
            elseif (len(gpuInfo) = 1) // If there's only one GPU return its model name
                gpuName = gpuInfo[1][:name]
            else  // If there's no GPU detected
                gpuName = "No GPU detected!"
            }
        else // Else (If the OS is (Unix-like))
            try {
                // Check if pciutils is installed
                result = systemCmd("which lspci")
                if (isNull(result)) {
                    return "Please install pciutils"
                }

                // Execute command to get GPU name
                gpuInfo = systemCmd("lspci -d *::0300 -mm")

                // Check if no GPU detected
                if (isNull(gpuInfo)) {
                    return "No GPU detected"
                }

                // Split the output by "
                gpuName = split(gpuInfo, '" ')
                // Remove any double-quotes
                gpuName = substr(gpuName[3], '"', "")
            catch // If an error occurred
                return "An error occurred while fetching GPU information: " + cCatchError 
            }
        }

        // Return GPU name
        return  gpuName
    }

    // Method to get currently running shell
    func shell() {
        // Get shell info from shellInfo
        shell = shellInfo()

        // Return the shell list
        return shell
    }

    // Method to get currently running terminal info (For Unix-like OSes)
    func term() {
        // Initialize term
        term = "Unknown"

        // Check if the OS is Unix-like
        if (isUnix()) {
            // Get currently running terminal from the TERM_PROGRAM env var
            termName = SysGet("TERM_PROGRAM")
            // Get currently running terminal version from the TERM_PROGRAM_VERSION env var
            termVersion = SysGet("TERM_PROGRAM_VERSION")
            // Combine termName and termVersion
            term = termName + " " + termVersion
        }
    
        // Return terminal info
        return term
    }
    
    func ram() {
        // Initialize the ramInfo list
        ramInfo = [
            :size = NULL,
            :used = NULL,
            :free = NULL,
            :swap = NULL
        ]

        // Check if the OS is Windows
        if (isWindows()) {
            // Get Ram info (size, used, free) from winSysInfo
            ramInfo = memoryInfo()
        elseif (isLinux()) // If the OS is Linux
            // Get raw memory info
            memInfo = memoryInfo()
        
            // Extract memory values in KB and convert to bytes
            totalBytes = memInfo[:MemTotal][1] * 1024
            freeBytes = memInfo[:MemAvailable][1] * 1024
            swapBytes = memInfo[:SwapTotal][1] * 1024
            usedBytes = totalBytes - freeBytes
            
            // Add size to ramInfo
            ramInfo[:size] = formatBytes(totalBytes)
            // Add used to ramInfo
            ramInfo[:used] = formatBytes(usedBytes)
            // Add free to ramInfo
            ramInfo[:free] = formatBytes(freeBytes)
            // Add swap to ramInfo
            ramInfo[:swap] = formatBytes(swapBytes)
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Get ramInfo from memoryInfo
            ramInfo = memoryInfo()
            // Add size to ramInfo
            ramInfo[:size] = formatBytes(ramInfo[1])
            // Add free to ramInfo 
            ramInfo[:free] = formatBytes(ramInfo[2] * ramInfo[3])
            // Add used to ramInfo
            ramInfo[:used] = formatBytes(ramInfo[1] - (ramInfo[2] * ramInfo[3]))
            // Add swap to ramInfo
            ramInfo[:swap] = formatBytes(ramInfo[4])
        }
                
        // Return Ram info
        return ramInfo
    }

    // Method to get storage disks info
    func storageDisks() {
        // Initialize the blockDevices list
        blockDevices = []
        // Initialize the StorageDisks list
        storageDisks = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get storage disks (name, size) from winSysInfo
            storageDisks = winSysInfo[:disks]
        elseif (isLinux()) // If the OS is Linux
            // Get blockdevices from StorageInfo
            storageDisks = storageInfo() 
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Use geom to get disk information
            diskOutput = systemCmd("geom disk list")
            
            // Process output and directly extract disk information
            diskLines = split(diskOutput, nl)
            currentDisk = ""
            
            for line in diskLines {
                line = trim(line)
                
                // Check if this is a disk name line
                if substr(line, "Geom name:") = 1 {
                    currentDisk = trim(substr(line, 11))
                }
                
                // Check if this is a disk size line
                if !isNull(currentDisk) and substr(line, "Mediasize:") = 1 {
                    // Extract the human-readable size
                    openParen = substr(line, "(")
                    closeParen = substr(line, ")")
                    
                    if openParen > 0 and closeParen > openParen {
                        diskSize = trim(substr(line, openParen + 1, closeParen - openParen - 1))
                        // Add disk to StorageDisks with both name and size
                        add(storageDisks, [:name = currentDisk, :size = diskSize])
                        currentDisk = "" // Reset for next disk
                    }
                }
            }        
        }

        // Return storage disks
        return storageDisks
    }

    // Method to get storage parts info
    func storageParts() { 
        // Initialize the storageParts list
        storageParts = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get storage parts from winSysInfo (name, size, used, free)
            storageParts = winSysInfo[:parts]
        else // Else (If the OS is Unix-like)
            // Get partition information using df
            partOutput = systemCmd("df -k")
            // Split the output by newlines
            partLines = split(partOutput, nl)
            
            // Skip the header line
            for i = 2 to len(partLines) {
                if (!isNull(partLines[i])) {
                    // Split the line by spaces
                    partInfo = split(partLines[i], " ")
                    // Remove empty elements
                    partInfo = filter(partInfo, func item { return !isNull(item) })
                    
                    if (len(partInfo) >= 6) {
                        // Get partition details
                        partName = partInfo[1]
                        partSize = partInfo[2]
                        partUsed = partInfo[3]
                        partFree = partInfo[4]
                        
                        // Only add if not in filteredStorageParts
                        if (!find(filteredStorageParts, partName)) {
                            add(storageParts, [:name = partName, :size = partSize, :used = partUsed, :free = partFree])
                        }
                    }
                }
            }
        }

        // Return storageParts
        return storageParts
    }

    // Method to get uptime
    func sysUptime(params) {
        // Get calculated uptimeInfo
        fUptime = calcUptime(uptime(), params)

        // Return uptime
        return fUptime
    }

    // Method to get System Architecture
    func arch() {
        // Get System Architecture
        sysArch = GetArch()
        
        // Standardize architecture naming across different OS
        switch (sysArch) {
            case "x64"
                sysArch = "amd64"
            case "x86"
                sysArch = "i386"
            case "arm64"
                sysArch = "aarch64"
            case "arm"
                sysArch = "armv7l"
            else
                sysArch = "unknown"
        }

        // Return System Architecture
        return sysArch
    }

    // Method to get Package/Program count
    func pCount() {
        // Default pCount value
        pCount = "Unknown"

        // Check if the OS is Windows
        if (isWindows()) {
            // Get installed programs count from winSysInfo
            pCount = winSysInfo[:pcount]
        else // Else (If the OS is (Unix-like))
            // Loop through every package manager
            for pManager in pManagers {
                // If your OS is supported get pCount
                if (find(pManager[2][:supported], osInfo()[:id])) {
                    pCount = systemCmd(pManager[2][:cmd]) + " (" + pManager[2][:name] + ")"                    
                }
            }
        }

        // Return package count
        return pCount
    }
    
    // Method to check if the machine is a VM
    func isVM() {
        // Check if the OS is Windows
        if (isWindows()) {
            isVM = winSysInfo[:isVM]
            
            return isVM
        elseif (isLinux()) // If the OS is Linux
            // Define a list of dmi file paths
            dmiPaths = [
                "/sys/class/dmi/id/product_name",
                "/sys/class/dmi/id/sys_vendor", 
                "/sys/class/dmi/id/board_vendor", 
                "/sys/class/dmi/id/bios_vendor",
                "/sys/class/dmi/id/product_version"
            ]

            // Loop through each dmi path to check for virtualization indicators
            for path in dmiPaths  {
                // Check if the current DMI path exists
                if (fexists(path)) {
                    // Read the content of the dmi file and split it into lines
                    dmiContent = split(readFile(path), nl)
                    // Check if any known virtualization indicator is present in dmiContent
                    for line in dmiContent {
                        if (find(virtIndicators, lower(trim(line)))) {
                            // Return true if a match is found
                            return true
                        }
                    }
                }
            }
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Check if the system is running in a VM
            vmInfo = systemCmd("sysctl -n kern.vm_guest")

            // Check if the VM info is not null
            if (!isNull(vmInfo)) {
                // Check if any known virtualization indicator is present in vmInfo
                if (find(virtIndicators, lower(vmInfo))) {
                    // Return true if a match is found
                    return true
                }
            }
        }

        // Return false if no virtualization indicators were found
        return false
    }

    // Method to get network interface information
    func network() {
        // Get network info from networkInfo
        networkInfo = networkInfo()

        // Return the network list
        return networkInfo
    }

    private

    // Helper function to get device model
    func modelInfo() {
        // Initialize model
        model = "Unknown"

        // Check if the OS is Windows
        if (isWindows()) {
            // Get the device model from winSysInfo List
            if (!isNull(winSysInfo[:model])) {
                model = winSysInfo[:model]
            }
        elseif (isLinux()) // If the OS is Linux
            // Define a list of dmi file paths
            dmiPaths = [
                "/sys/class/dmi/id/product_name",
                "/sys/class/dmi/id/product_version",
                "/sys/class/dmi/id/board_name"
            ]

            // Loop through each dmi path to get the model
            for path in dmiPaths {
                if (fexists(path)) {
                    fileContent = trim(readFile(path))
                    if (!isNull(fileContent) and len(fileContent) > 0) {
                        model = substr(fileContent, nl, "")
                        return model
                    }
                }
            }
        elseif (isFreeBSD()) // If the OS is FreeBSD
            model = trim(systemCmd("sysctl -n hw.model"))
        }

        // Return the model
        return model
    }
    
    // Helper function to get osInfo
    func osInfo() {
        // Initialize the OS info list
        osInfo = [
            :name = "Unknown",
            :id = "unknown"
        ]
        
        // Check if the OS is Windows
        if (isWindows()) {
            // Get the OS name from winSysInfo List
            osInfo[:name] = winSysInfo[:os]    
            // Set the OS id to windows
            osInfo[:id] = "windows"
        else // Else (If the OS is (Unix-like))
            // Read /etc/os-release content
            content = readFile("/etc/os-release")
            // Remove any double-quoets
            content = substr(content, '"', '')

            // Convert the content string lines into a list 
            lines = str2List(content)
            // Loop through every line
            for line in lines {
                // Check if PRETTY_NAME= exists
                if (substr(line, 1, 12) = "PRETTY_NAME=") {
                
                    // Get the OS name
                    osInfo[:name] = substr(line, 13)
                    
                // Check if ID= exists
                elseif (substr(line, 1, 3) = "ID=")
                
                    // Get the OS ID
                    osInfo[:id] = substr(line, 4)
                }
            }
        }

        // Return the osInfo        
        return osInfo
    }

    // Helper function to get Kernel info
    func kernelInfo() {
        // kVersion default value
        kVersion = "Unknown"

        // Check if the OS is Windows
        if (isWindows()) {
            // Get Windows NT Kernel version from winSysInfo
            kVersion = winSysInfo[:version]
        elseif (isLinux()) // If the OS is Linux
            // Read and get the Kernel info from /proc/version
            kInfo = readFile("/proc/version")
            
            // Check if version exists
            vStartIndex = substr(kInfo, "version ")
            // if version exists, return the kernel version only
            if (vStartIndex > 0) {
                vStartIndex += 8
                vSubstring = substr(kInfo, vStartIndex, len(kInfo) - vStartIndex + 1)
                vEndIndex = substr(vSubstring, " ")
                if (vEndIndex > 0) {
                    kVersion = left(vSubstring, vEndIndex - 1)
                }
            }
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Get the Kernel version using sysctl
            kInfo = systemCmd("sysctl kern.osrelease")
            // Split the output by ":"
            kInfo = split(kInfo, ":")
            // Check if the length of kInfo is greater than 1
            if (len(kInfo) > 1) {
                // Get the kernel version
                kVersion = trim(kInfo[2])
            }
        }

        // Return Windows NT Kernel version
        return kVersion
    }

    // Helper function to get CPU info
    func cpuInfo() {
        // Initialize the CPU info list
        cpuInfo = [
            :count = 1,
            :model = "Unknown",
            :cores = "0",
            :threads = "0",
            :usage = NULL,
            :temp = NULL,
            :cpus = []
        ]

        // Check if the OS is Windows
        if (isWindows()) {
            // Get CPU info from the winSysInfo list
            cpuInfo = winSysInfo[:cpu]
        elseif (isLinux()) // If the OS is Linux
            // Read and get CPU info content
            content = readFile("/proc/cpuinfo")
            
            // Convert the CPU info content string lines into a list  
            lines = str2List(content)
            
            // Initialize counters
            physicalIDs = []
            modelName = ""
            coresPerCPU = 0
            
            // First get CPU model
            for line in lines {
                if (substr(line, "model name") and modelName = "") {
                    colonPos = substr(line, ":")
                    if (colonPos > 0) {
                        modelName = trim(substr(line, colonPos + 1))
                        break
                    }
                }
            }
            
            // Count unique physical CPUs
            for line in lines {
                if (substr(line, "physical id")) {
                    colonPos = substr(line, ":")
                    if (colonPos > 0) {
                        physID = trim(substr(line, colonPos + 1))
                        if (!find(physicalIDs, physID)) {
                            add(physicalIDs, physID)
                        }
                    }
                }
            }
            
            // Get cores per physical CPU
            for line in lines {
                if (substr(line, "cpu cores")) {
                    colonPos = substr(line, ":")
                    if (colonPos > 0) {
                        coresPerCPU = number(trim(substr(line, colonPos + 1)))
                        break
                    }
                }
            }
            
            // Count total threads (processors)
            totalThreads = 0
            for line in lines {
                if (substr(line, "processor")) {
                    totalThreads++
                }
            }
            
            // Set CPU info
            physicalCPUCount = len(physicalIDs)
            if physicalCPUCount = 0 { physicalCPUCount = 1 }
            if coresPerCPU = 0 { coresPerCPU = 1 }

            cpuInfo[:model] = modelName
            cpuInfo[:count] = physicalCPUCount
            cpuInfo[:cores] = string(coresPerCPU * physicalCPUCount)
            cpuInfo[:threads] = string(totalThreads)

            // Initialize CPU specific info
            cpuInfo[:cpus] = []
            add(cpuInfo[:cpus], [
                :number = 1,
                :model = modelName,
                :cores = string(coresPerCPU * physicalCPUCount),
                :threads = string(totalThreads)
            ])

            // Get CPU usage and temperature
            // Get initial CPU stats (CPU load)
            initialStats = split(substr(split(readFile("/proc/stat"), nl)[1], 6), " ")
            
            // Sleep for 0.1 seconds (to update the CPU stats)
            sleep(0.1)

            // Get updated CPU stats after the sleep period (CPU load)
            updatedStats = split(substr(split(readFile("/proc/stat"), nl)[1], 6), " ")

            // Initialize diffs list
            diffs = []

            // Calculate the diffs between updated and initial stats
            for i = 1 to len(initialStats) {
                // Subtract initial value from updated value and add the diff to the diffs list
                add(diffs, updatedStats[i] - initialStats[i])
            }

            // Get calculated CPU usage
            cpuInfo[:usage] = 100 * (sumlist(diffs) - diffs[4]) / sumlist(diffs)

            // tempFile value
            tempFile = "/sys/class/thermal/thermal_zone0/temp"
            
            // Check if tempFile exists (because VMs don't have this file)
            if (fexists(tempFile)) {
                // Get CPU temp
                cpuTemp = number(readFile(tempFile))
                // Convert CPU temp from millidegrees to degrees
                cpuInfo[:temp] = cpuTemp / 1000
            else // If tempFile doesn't exist
                cpuInfo[:temp] = NULL
            }
        
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Get CPU info using sysctl
            cpuOutput = systemCmd("sysctl -n hw.model hw.ncpu")
            // Split the output by newlines
            cpuLines = split(cpuOutput, nl)
            // Check if we have at least 2 lines of output
            if (len(cpuLines) >= 2) {
                // Get the CPU model name
                cpuInfo[:model] = trim(cpuLines[1])
                // Get the number of CPUs
                cpuCount = number(trim(cpuLines[2]))
                cpuInfo[:count] = cpuCount
                // Set the number of cores and threads to the same value
                cpuInfo[:cores] = string(cpuCount)
                cpuInfo[:threads] = string(cpuCount)
                
                // Initialize CPU specific info
                cpuInfo[:cpus] = []
                add(cpuInfo[:cpus], [
                    :number = 1,
                    :model = cpuInfo[:model],
                    :cores = cpuInfo[:cores],
                    :threads = cpuInfo[:threads]
                ])
            }
            
            // Get CPU usage
            // Get initial CPU stats
            initialStats = systemCmd("sysctl -n kern.cp_time")
            initialStats = split(initialStats, " ")
            
            // Sleep for 0.1 seconds (to update the CPU stats)
            sleep(0.1)
            
            // Get updated CPU stats after the sleep period
            updatedStats = systemCmd("sysctl -n kern.cp_time")
            updatedStats = split(updatedStats, " ")
            
            // Convert string values to numbers and calculate differences
            diffs = []
            totalDiff = 0
            for i = 1 to len(initialStats) {
                diffValue = number(updatedStats[i]) - number(initialStats[i])
                add(diffs, diffValue)
                totalDiff += diffValue
            }
            
            // Calculate CPU usage (in FreeBSD, the last value is idle time)
            idleIndex = len(diffs)
            if (totalDiff > 0) {
                cpuInfo[:usage] = 100 * (totalDiff - diffs[idleIndex]) / totalDiff
            else
                cpuInfo[:usage] = 0
            }
            
            // Check if the system is not a VM
            if (!isVM()) {
                tempInfo = systemCmd("sysctl -n dev.cpu.0.temperature")
                if (!isNull(tempInfo)) {
                    cpuInfo[:temp] = number(substr(tempInfo, 1, len(tempInfo) - 2))
                }
            }
        }

        // Return the CPU info list
        return cpuInfo
    }

    // Helper function to get shell info
    func shellInfo() {
        // Initialize the shell list with default values
        shell = [
            :name = "Unknown",
            :version = "Unknown"
        ]

        // Check if the OS is Windows
        if (isWindows()) {
            // Get currently running shell name and version from winSysInfo
            shell = winSysInfo[:shell]
            
        else // Else (If the OS is (Unix-like))
            // Get currently running shell from the system environment
            shellInfo = SysGet("SHELL")
            // Get shell name only from its path e.g. /usr/bin/fish --> fish
            shell[:name] = JustFileName(shellInfo)
            // Initialize shellVersion
            shellVersion = "Unknown"
            // Skip version check for sh and dash shells since they don't support --version
            if !(shell[:name] = "sh" or shell[:name] = "dash") {
                // Execute the shell with the version argument to retrieve the shell version
                shellVersion = systemCmd(shellInfo + " --version")
            }

            // Switch statement to determine the shell type and extract its version
            switch shell[:name] {
                case "sh"
                    shell[:version] = systemCmd("strings $(which dash) | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1")
                case "dash"
                    shell[:version] = systemCmd("strings $(which dash) | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1")
                case "bash"
                    // Find the position of the version number in the shellVersion string
                    versionPos = substr(shellVersion, "version ") + len("version ")
                    // Extract the version number from the shellVersion string
                    shell[:version] = substr(shellVersion, versionPos, substr(shellVersion, "(") - versionPos)
                case "fish"
                    // Find the position of the version number in the shellVersion string
                    versionPos = substr(shellVersion, "version ") + len("version ")
                    // Extract the version number from the shellVersion string
                    shell[:version] = substr(shellVersion, versionPos)
                case "zsh"
                    // Find the position of the version number in the shellVersion string
                    versionPos = substr(shellVersion, "zsh ") + len("zsh ")
                    // Extract the version number from the shellVersion string
                    shell[:version] = substr(shellVersion, versionPos)
                case "tcsh"
                    // Find the position of the version number in the ShellVersion string
                    versionPos = substr(shellVersion, "tcsh ") + len("tcsh ")
                    // Extract the version number from the shellVersion string
                    shell[:version] = substr(shellVersion, versionPos, substr(shellVersion, "(") - versionPos)
                case "ksh"
                    // Find the position of the version number in the shellVersion string
                    versionPos = substr(shellVersion, "/") + len("/")
                    // Extract the version number from the shellVersion string
                    shell[:version] = substr(shellVersion, versionPos)                    
                else
                    shell[:name] = "Unknown"
                    shell[:version] = "Unknown"
            }
        }
        
        // Return the shell list
        return shell
    }

    // Helper function to get Memory info
    func memoryInfo() {
        // Initialize the memInfo list
        memInfo = []
        
        // Check if the OS is Windows
        if (isWindows()) {
            // Get Ram info (size, used, free) from winSysInfo
            memInfo = winSysInfo[:ram]
        elseif (isLinux()) // If the OS is Linux
            // Read and get meminfo 
            content = readFile("/proc/meminfo")

            // Convert the content string lines into a list  
            lines = str2List(content)

            // Loop through every line  
            for line in lines {
                // Find the position of the colon
                colonPos = substr(line, ":")
                if (colonPos > 0) {
                    key = trim(left(line, colonPos - 1))
                    valueStr = trim(right(line, len(line) - colonPos))
            
                    // Split the value string into value and unit
                    spacePos = substr(valueStr, " ")
                    if (spacePos > 0) {
                        value = number(left(valueStr, spacePos - 1))
                        unit = trim(right(valueStr, len(valueStr) - spacePos))
                        // Store raw KB values for formatting later
                        memInfo[key] = [value, unit]
                    else
                        value = number(valueStr)
                        memInfo[key] = [value]
                    }
                }
            }
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Get memory info using sysctl
            memInfoRaw = systemCmd("sysctl -n hw.physmem vm.stats.vm.v_free_count vm.stats.vm.v_page_size vm.swap_total")
            // Split the output by newlines
            memInfoLines = split(memInfoRaw, nl)
            
            // Process FreeBSD memory info - store raw values
            if (len(memInfoLines) >= 4) {
                physmem = number(memInfoLines[1])
                freeCount = number(memInfoLines[2])
                pageSize = number(memInfoLines[3])
                swapTotal = number(memInfoLines[4])
                
                memInfo = [
                    physmem,
                    freeCount,
                    pageSize,
                    swapTotal
                ]
            else
                memInfo = split(memInfoRaw, nl)
            }
        }

    
        // Return Ram info
        return memInfo
    }
    
    // Helper function to calculate uptime based on uptimeInfo and the given params list
    func calcUptime(uptimeInfo, params) {
        // Set default parameter values if not provided, not a list, or the list is empty
        if (!isList(params) or len(params) = 0) {
            params = [:days = 1, :hours = 1, :minutes = 1, :seconds = 1]
        }
        
        // Convert uptimeInfo from 0.1 ms to seconds
        totalSeconds = floor(uptimeInfo / 10000000)

        // Format the uptime string
        fUptime = ""
        for tUnit in tUnits {
            if (params[tUnit[3]] = 1) {
                value = floor(totalSeconds / tUnit[1])
                if (value > 0 or len(fUptime) > 0) {
                    if (len(fUptime) > 0) {
                        fUptime += ", "
                    }
                    fUptime += string(value) + " " + tUnit[2]
                    if (value != 1) {
                        fUptime += "s"
                    }
                    totalSeconds = totalSeconds % tUnit[1]
                }
            }
        }

        // Return uptime
        return fUptime
    }

    // Helper function to get Storage Info (For Linux)
    func storageInfo() {
        // Initialize the blockDevices list
        blockDevices = []

        // Read /proc/partitions to get block devices
        storageInfo = readFile("/proc/partitions")

        // Split the storageInfo by newlines
        aLines = split(storageInfo, nl)

        // Start loop after the header lines
        for i = 3 to len(aLines) {
            cLine = trim(aLines[i])

            // Skip empty lines
            if (!len(cLine)) {
                continue
            }

            // Split the line into columns
            aParts = split(cLine, " ")

            // A valid disk line should have 4 parts
            if (len(aParts) = 4) {
                cName = aParts[4]
                nSize = number(aParts[3])

                // Check if the last character of the name is NOT a digit
                // This identifies parent disks like 'sda', 'sdb', 'nvme0n1'
                cLastChar = right(cName, 1)
                if (!isdigit(cLastChar)) {
                    // Create a structured list for this disk
                    aDiskInfo = [
                        :name = cName,
                        :size = nSize
                    ]
                    add(blockDevices, aDiskInfo)
                }
            }
        }

        // Return blockDevices
        return blockDevices
    }

    // Helper function to get network interface information
    func networkInfo() {
        // Initialize the networkInfo list
        networkInfo = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get network info from winSysInfo
            networkInfo = winSysInfo[:network]
        elseif (isLinux()) // If the OS is Linux
            // Get network interfaces using ip command
            try {
                // Check if ip command is available
                result = systemCmd("which ip")
                if (isNull(result)) {
                    // Fallback to ifconfig
                    interfaceOutput = systemCmd("ifconfig")
                    networkInfo = parseIfconfig(interfaceOutput)
                else
                    // Use ip command for better output
                    interfaceOutput = systemCmd("ip -o addr show")
                    networkInfo = parseIpAddr(interfaceOutput)
                }
            catch
                // Return empty list on error
                return []
            }
        elseif (isFreeBSD()) // If the OS is FreeBSD
            // Use ifconfig for FreeBSD
            try {
                interfaceOutput = systemCmd("ifconfig")
                networkInfo = parseIfconfig(interfaceOutput)
            catch
                // Return empty list on error
                return []
            }
        }

        // Return network interface information
        return networkInfo
    }

    // Helper function to parse ip addr output (For Linux)
    func parseIpAddr(output) {
        // Initialize interfaces list
        interfaces = []
        
        // Split output by lines
        lines = split(output, nl)
        
        for line in lines {
            if (!isNull(line) and len(trim(line)) > 0) {
                // Parse each line of ip addr output
                parts = split(line, " ")
                
                if (len(parts) >= 4) {
                    interfaceIndex = parts[1]
                    // Remove trailing colon
                    interfaceName = substr(parts[2], 1, len(parts[2]) - 1)
                    
                    // Skip if not an inet address
                    if (parts[3] != "inet") {
                        loop
                    }
                    
                    ipWithMask = parts[4]
                    ipParts = split(ipWithMask, "/")
                    ipAddress = ipParts[1]
                    
                    // Skip loopback unless it's the only interface
                    if (interfaceName = "lo" and len(interfaces) > 0) {
                        loop
                    }
                    
                    // Check if interface already exists in our list
                    found = false
                    for i = 1 to len(interfaces) {
                        if (interfaces[i][:name] = interfaceName) {
                            found = true
                            break
                        }
                    }
                    
                    if (!found) {
                        add(interfaces, [
                            :name = interfaceName,
                            :ip = ipAddress,
                            :status = "up"
                        ])
                    }
                }
            }
        }
        
        return interfaces
    }

    // Helper function to parse ifconfig output (For FreeBSD and Linux)
    func parseIfconfig(output) {
        interfaces = []
        lines = split(output, nl)
        currentInterface = ""
        currentIP = ""
        
        for raw_line in lines {
            trimmed_line = trim(raw_line)
            
            if (!len(trimmed_line)) {
                loop
            }
            
            // Check if this is a new interface line
            isInterfaceLine = false
            // Check indentation on raw_line
            if (substr(raw_line, 1, 1) != " ") {
                colonPos = substr(trimmed_line, ":")
                if (colonPos > 0) {
                    potentialName = left(trimmed_line, colonPos - 1)
                    // Ensure potentialName is a valid interface name
                    if (len(potentialName) > 0 and !substr(potentialName, " ")) {
                        if lower(potentialName) != "status" and lower(potentialName) != "media" and lower(potentialName) != "options" and lower(potentialName) != "ether" and lower(potentialName) != "groups" {
                           isInterfaceLine = true
                        }
                    }
                }
            }

            if (isInterfaceLine) {
                if (!isNull(currentInterface) and !isNull(currentIP)) {
                    add(interfaces, [
                        :name = currentInterface,
                        :ip = currentIP,
                        :status = "up"
                    ])
                }
                
                colonPos = substr(trimmed_line, ":") 
                currentInterface = left(trimmed_line, colonPos - 1)
                currentIP = ""
            
            elseif (!isNull(currentInterface) and (substr(trimmed_line, "inet ") or substr(trimmed_line, "inet addr:")))
                ipLineContent = ""
                if (substr(trimmed_line, "inet addr:")) {
                    ipLineContent = trim(substr(trimmed_line, substr(trimmed_line, "inet addr:") + len("inet addr:")))
                elseif (substr(trimmed_line, "inet "))
                    ipLineContent = trim(substr(trimmed_line, substr(trimmed_line, "inet ") + len("inet ")))
                }

                if (!isNull(ipLineContent)) {
                    tempIP = ""
                    spacePos = substr(ipLineContent, " ")
                    if (spacePos > 0) {
                        tempIP = left(ipLineContent, spacePos - 1)
                    else
                        tempIP = ipLineContent
                    }
                    
                    if (!substr(tempIP, ":") and currentIP = "") {
                        currentIP = tempIP
                    }
                }
            }
        }
        
        // Add the last interface found, if it has an IP
        if (!isNull(currentInterface) and !isNull(currentIP)) {
            add(interfaces, [
                :name = currentInterface,
                :ip = currentIP,
                :status = "up"
            ])
        }
        
        return interfaces
    }
    
    // Helper function to read the contents of a file
    func readFile(file) {
        // Open the specified file in read-only mode
        fp = fopen(file, "r")
        // Read up to 102400 bytes from the file
        result = fread(fp, 102400)
        // Close the file stream
        fclose(fp)

        // Return the contents from the file
        return result
    }

    // Helper function to format bytes into appropriate units
    func formatBytes(bytes) {
        // Handle null values
        if (isNull(bytes)) {
            return 0
        }
        
        // Convert to number if it's a string
        numBytes = 0
        if (isString(bytes)) {
            numBytes = number(bytes)
        else
            numBytes = bytes
        }
        
        // Handle zero or negative values
        if (numBytes <= 0) {
            return 0
        }
        
        // Convert to MB and round to 2 decimal places
        mbValue = numBytes / 1024 / 1024
        
        // Return the numeric value only
        return floor(mbValue * 100) / 100
    }
}