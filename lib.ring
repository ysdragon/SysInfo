/*
    Author: ysdragon (https://github.com/ysdragon)
*/

load "stdlibcore.ring"
load "jsonlib.ring"
load "constants.ring"

class SysInfo {
    
    // Check if the OS is Windows
    if (isWindows()) {
        // Create a temporary PowerShell script file in the %TEMP% directory
        psTempScript = tempname() + ".ps1"
        // Open the file for writing
        fp = fopen(psTempScript, "w")
        // Write the content of PS_SCRIPT to the temp PowerShell file
        fwrite(fp, PS_SCRIPT)
        // Close the file stream
        fclose(fp)
        // Execute the temp PowerShell script
        cmd = systemCmd("powershell -NoProfile -ExecutionPolicy Bypass -File " + psTempScript)
        // Convert the returned JSON to a list
        winSysInfo = json2List(cmd)
        // Delete the temp PowerShell script
        OSDeleteFile(psTempScript)
    }

    // Function to get the hostname
    func hostname() {
        // Execute command to get hostname
        hostname = systemCmd("hostname")
    
        // Return hostname
        return hostname
    }

    // Function to get the username
    func username() {
        // Check if the OS is Windows
        if (isWindows()) {
            // Get the USERNAME environment variable

            return SysGet("USERNAME")
        else // Else (If the OS is (Unix-like))

            // Get the USER environment variable
            return SysGet("USER")
        }
    }

    // Function to get OS name
    func os() {
        // Get osInfo
        osInfo = osInfo()

        // Return the OS info
        return osInfo
    }

    // Function to get the Kernel version
    func version() {
        // Get the Kernel version from kernelInfo
        kVersion = kernelInfo()

        // Return the Kernel version
        return kVersion
    }

    // Function to get CPU name, cores and threads
    func cpu() {
        // Get CPU info from cpuInfo
        cpuInfo = cpuInfo()          

        // Return cpuInfo
        return cpuInfo
    }

    // Function to get GPU name
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

    // Function to get currently running shell
    func shell() {
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
            ShellInfo = SysGet("SHELL")
            // Get shell name only from its path e.g. /usr/bin/fish --> fish
            shell[:name] = JustFileName(ShellInfo)
            // Execute the shell with the version argument to retrieve the shell version
            ShellVersion = systemCmd(ShellInfo + " --version")

            // Switch statement to determine the shell type and extract its version
            switch shell[:name] {
                case "bash"
                    // Find the position of the version number in the ShellVersion string
                    versionPos = substr(ShellVersion, "version ") + len("version ")
                    // Extract the version number from the ShellVersion string
                    shell[:version] = substr(ShellVersion, versionPos, substr(ShellVersion, "(") - versionPos)
                case "fish"
                    // Find the position of the version number in the ShellVersion string
                    versionPos = substr(ShellVersion, "version ") + len("version ")
                    // Extract the version number from the ShellVersion string
                    shell[:version] = substr(ShellVersion, versionPos)
                case "zsh"
                    // Find the position of the version number in the ShellVersion string
                    versionPos = substr(ShellVersion, "zsh ") + len("zsh ")
                    // Extract the version number from the ShellVersion string
                    shell[:version] = substr(ShellVersion, versionPos)
                case "tcsh"
                    // Find the position of the version number in the ShellVersion string
                    versionPos = substr(ShellVersion, "tcsh ") + len("tcsh ")
                    // Extract the version number from the ShellVersion string
                    shell[:version] = substr(ShellVersion, versionPos, substr(ShellVersion, "(") - versionPos)
                case "ksh"
                    // Find the position of the version number in the ShellVersion string
                    versionPos = substr(ShellVersion, "/") + len("/")
                    // Extract the version number from the ShellVersion string
                    shell[:version] = substr(ShellVersion, versionPos)                    
            }
        }
        
        // Return the shell list
        return shell
    }

    // Function to get currently running terminal info (For Unix-like OSes)
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
        ramInfo = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get Ram info (size, used, free) from winSysInfo
            ramInfo = memoryInfo()
        else // Else (If the OS is (Unix-like))
            // Get ramInfo from memoryInfo
            ramInfo = memoryInfo()
        
            // Get totalRam and convert the value from KB to GB
            totalRam = ramInfo[:MemTotal][1] / 1024 / 1024

            // Get freeRam and convert the value from KB to GB
            freeRam = ramInfo[:MemAvailable][1] / 1024 / 1024
            
            // Add size to ramInfo
            ramInfo[:size] = totalRam
            // Calculate and add used to ramInfo
            ramInfo[:used] = totalRam - freeRam
            // Add free to ramInfo
            ramInfo[:free] = freeRam
        }
                
        // Return Ram info
        return ramInfo
    }

    // Function to get storage disks info
    func storageDisks() {
        // Initialize the blockDevices list
        blockDevices = []
        // Initialize the StorageDisks list
        storageDisks = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get storage disks (name, size) from winSysInfo
            storageDisks = winSysInfo[:disks]
        else // Else (If the OS is (Unix-like))
            // Get blockdevices from StorageInfo
            blockDevices = storageInfo()
            
            // Loop in every blockdevice in blockDevices
            for blockDevice in blockDevices {
                // Add blockDevice name and size to StorageDisks
                add(storageDisks, [:name = blockDevice[:name], :size = blockDevice[:size]])
            }
        }

        // Return storage disks
        return storageDisks
    }

    // Function to get storage parts info
    func storageParts() { 
        // Initialize the blockDevices list
        blockDevices = []
        // Initialize the storageParts list
        storageParts = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get storage parts from winSysInfo (name, size, used, free)
            storageParts = winSysInfo[:parts]
        else // Else (If the OS is (Unix-like))
            // Get blockdevices from StorageInfo
            blockDevices = storageInfo()

            // Loop every blockDevice in blockDevices
            for blockDevice in blockDevices {
                // Loop every children in blockDevice (disk part)
                for children in blockDevice[:children] {
                    // Check if mountpoint is not null
                    if (!isNull(children[:mountpoint])) {
                        // Get partition info
                        childrenInfo = systemCmd("df -h | grep '" + children[:name] + "' | awk '{print $1, $2, $3, $4}'")
                        // Split the output into lines
                        childrenInfo = split(childrenInfo, nl)

                        // Loop through partition info
                        for info in childrenInfo {
                            if (!isNull(info)) {
                                // Split the output
                                childrenInfoList = split(info, " ")

                                // Get childrenName (part name)
                                childrenName = childrenInfoList[1]
                                // Get childrenSize (part size)
                                childrenSize = childrenInfoList[2]
                                // Get childrenUsed (part used size)
                                childrenUsed = childrenInfoList[3]
                                // Get childrenFree (part free size)
                                childrenFree = childrenInfoList[4]

                                // Add children (part) to StorageParts
                                add(storageParts, [:name = childrenName, :size = childrenSize, :used = childrenUsed, :free = childrenFree])
                            }
                        }
                    }
                }
            }
        }

        // Return storageParts
        return storageParts
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
    
    // Function to check if the machine is a VM
    func isVM() {
        // Initialize isVM
        isVM = NULL

        // Check if the OS is Windows
        if (isWindows()) {
            isVM = winSysInfo[:isVM]
        else // Else (If the OS is (Unix-like))
            // Get cpuInfo from /proc/cpuinfo
            cpuInfo = readFile("/proc/cpuinfo")
            
            // List of virtualization indicators to check
            virtIndicators = ["hypervisor", "kvm", "vmware", "vbox", "xen", "qemu", "docker"]

            // Loop through virtIndicators list
            for virt in virtIndicators {
                // Determine if it's a VM
                if (substr(cpuInfo, virt)) {  
                    // Return true if the machine is a VM
                    isVM = true
                }
            }
        }

        // Return isVM
        return isVM
    }

    private

    // Function to get osInfo
    func osInfo() {
        // Initialize the osInfo list
        osInfo = []

        // OS name default value
        osInfo[:name] = "Unknown"
        // OS id default value
        osInfo[:id] = "unknown"

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

    // Function to get Kernel info
    func kernelInfo() {
        // kVersion default value
        kVersion = "Unknown"

        // Check if the OS is Windows
        if (isWindows()) {
            // Get Windows NT Kernel version from winSysInfo
            kVersion = winSysInfo[:version]
        else // Else (If the OS is (Unix-like))
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
        }

        // Return Windows NT Kernel version
        return kVersion
    }

    // Function to get CPU info
    func cpuInfo() {
        // Initialize the cpuInfo list
        cpuInfo = []

        // Check if the OS is Windows
        if (isWindows()) {
            // Get CPU info from the winSysInfo list
            cpuInfo = winSysInfo[:cpu]
        else // Else (If the OS is (Unix-like))
            // Initialize cpuInfo list
            cpuInfo = [
                :name = "Unknown",
                :cores = "0",
                :threads = "0",
                :usage = NULL,
                :temp = NULL
            ]

            // Read and get cpuinfo content
            content = readFile("/proc/cpuinfo")

            // Convert the content string lines into a list  
            lines = str2List(content)

            // processorCount default value
            processorCount = 0
            // coreCount default value
            coreCount = 0
            
            // siblings default value
            siblings = 0
            
            // Loop through every line
            for line in lines {
                // Check if the model name string exists
                if (substr(line, "model name")) {
                    // Find the position of the colon
                    colonPos = substr(line, ":")
                    if (colonPos > 0) {
                        cpuInfo[:name] = trim(substr(line, colonPos + 1))
                    }

                // Check if the processor string exists
                elseif (substr(line, "processor"))
                    processorCount++

                // Check if siblings info exists
                elseif (substr(line, "siblings"))
                    // Find the position of the colon
                    colonPos = substr(line, ":")
                    if (colonPos > 0) {
                        siblings = number(trim(substr(line, colonPos + 1)))
                    }

                // Check if the cpu cores string exists
                elseif (substr(line, "cpu cores"))
                    // Find the position of the colon
                    colonPos = substr(line, ":")
                    if (colonPos > 0) {
                        coreCount = number(trim(substr(line, colonPos + 1)))
                    }
                }
            }

            // Set threads count - use siblings if available, otherwise use processor count
            if siblings > 0 {
                cpuInfo[:threads] = string(siblings)
            else
                cpuInfo[:threads] = string(processorCount)
            }
            
            // If coreCount greater than 0, set the coreCount to :cores 
            if (coreCount > 0) {
                cpuInfo[:cores] = string(coreCount)
            else // Else (if the coreCount is equal to 0, set threads to :cores)
                cpuInfo[:cores] = cpuInfo[:threads]
            }

            // Get initial CPU stats (CPU load)
            initialStats = split(substr(split(readFile("/proc/stat"), nl)[1], 6), " ")
            
            // Sleep for 0.1 seconds (to update the CPU stats)
            sleep(0.1)

            // Get updated CPU stats after the sleep period (CPU load)
            updatedStats = split(substr(split(readFile("/proc/stat"), nl)[1], 6), " ")

            // Initialize diffs list
            diffs = []

            // Calculate the diffs between updated and initial stats
            for i = 1 to len(initialStats)
                // Subtract initial value from updated value and add the diff to the diffs list
                add(diffs, updatedStats[i] - initialStats[i])
            next

            // Get calculated CPU usage
            cpuInfo[:usage] = 100 * (sumlist(diffs) - diffs[4]) / sumlist(diffs)

            // tempFile value
            tempFile = "/sys/class/thermal/thermal_zone0/temp"
            
            // Check if tempFile exists (because VMs don't have this file)
            if (fexists(tempFile)) {
                // Get CPU temp
                cpuTemp = number(readFile(tempFile))
                // Convert CPU temp from millidegrees to degrees
                cpuInfo[:temp]  = cpuTemp / 1000
            else // If tempFile doesn't exist
                cpuInfo[:temp] = NULL
            }
        }

        // Return CPU info
        return cpuInfo
    }

    // Function to get Memory info
    func memoryInfo() {
        // Initialize the memInfo list
        memInfo = []
        
        // Check if the OS is Windows
        if (isWindows()) {
            // Get Ram info (size, used, free) from winSysInfo
            memInfo = winSysInfo[:ram]
        else // Else (If the OS is (Unix-like))
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
            
                    // Split the value string into value
                    spacePos = substr(valueStr, " ")
                    if (spacePos > 0) {
                        value = number(left(valueStr, spacePos - 1))
                    else
                        value = number(valueStr)
                    }
                        
                    memInfo[key] = [value]
                }
            }
        }

    
        // Return Ram info
        return memInfo
    }
    
    // Function to calculate uptime based on uptimeInfo and the given params list
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

    // Function to get Storage Info (For Unix-like OSes)
    func storageInfo() {
        // Initialize the blockDevices list
        blockDevices = []
        
        try {
            // Execute command to get storage info
            storageInfo = systemCmd("lsblk --json -o NAME,SIZE,FSTYPE,MOUNTPOINT")
            
            // Convert json to list
            storageInfo = json2List(storageInfo)
            
            // Get blockdevices from StorageInfo
            blockDevices = storageInfo[:blockdevices]
        catch
            // Handle errors
            ? "Error: " + cCatchError
        }

        // Return blockDevices
        return blockDevices
    }

    // Function to read the contents of a file
    func readFile(file) {
        // Open the specified file in read-only mode
        fp = fopen(file, "r")
        // Read up to 4096 bytes from the file
        result = fread(fp, 4096)
        // Close the file stream
        fclose(fp)

        // Return the contents from the file
        return result
    }
}