/*
    RingFetch GUI - A graphical system information display tool
    Author: ysdragon (https://github.com/ysdragon)
    
    This example demonstrates how to create a GUI application using LibUI 
    and the SysInfo package.
    
    Features:
    - System Overview (hostname, username, OS info, environment)
    - Hardware Information (CPU, RAM, GPU with temperature monitoring)
    - Storage Information (physical disks and mounted partitions)
    - Network Interfaces (active network connections with IP addresses)
*/

load "libui.ring"
load "SysInfo.ring"

func main() {
    // Initialize the SysInfo class to access system information methods
    sys = new SysInfo

    // ===========================================
    // SYSTEM INFORMATION RETRIEVAL
    // ===========================================
    
    // Device model
    model = sys.model()

    // Basic system identification
    hostname = sys.hostname()
    username = sys.username()
    shell = sys.shell()[:name] + " " + sys.shell()[:version]
    osName = sys.os()[:name]
    arch = sys.arch()
    kernelVer = sys.version()
    pcount = sys.pCount()
    uptime = sys.sysUptime([])

    // CPU information with performance metrics
    cpuModel = sys.cpu()[:model]
    cpuCores = string(sys.cpu()[:cores])
    cpuThreads = string(sys.cpu()[:threads])
    cpuUsage = string(sys.cpu()[:usage]) + "%"

    // Memory statistics
    totalRam = sys.ram()[:size]
    usedRam = sys.ram()[:used]
    freeRam = sys.ram()[:free]
    swapRam = sys.ram()[:swap]

    // Graphics hardware information
    gpuInfo = sys.gpu()

    // Storage devices and partitions
    disks = sys.storageDisks()
    parts = sys.storageParts()

    // Network interface information
    networkInfo = sys.network()

    // ===========================================
    // GUI WINDOW SETUP
    // ===========================================
    
    // Create the main application window with title and dimensions
    mainWindow = uiNewWindow("RingFetch GUI - System Information Tool", 600, 500, 0)
    uiWindowOnClosing(mainWindow, "onClosing()")
    uiWindowSetMargined(mainWindow, 1)

    // Main container for all GUI elements
    mainBox = uiNewVerticalBox()
    uiBoxSetPadded(mainBox, 1)
    uiWindowSetChild(mainWindow, uiControl(mainBox))

    // Create tabbed interface for organized information display
    mainTab = uiNewTab()
    uiBoxAppend(mainBox, uiControl(mainTab), 1)

    // ===========================================
    // SYSTEM OVERVIEW TAB
    // ===========================================
    
    sysInfoPage = uiNewVerticalBox()
    uiBoxSetPadded(sysInfoPage, 1)
    uiTabAppend(mainTab, "💻 System Overview", uiControl(sysInfoPage))

    // Host Information Group - Basic system identification
    hostGroup = uiNewGroup("Host Information")
    uiGroupSetMargined(hostGroup, 1)
    hostBox = uiNewVerticalBox()
    uiBoxSetPadded(hostBox, 1)

    hostForm = uiNewForm()
    uiFormSetPadded(hostForm, 1)
    uiFormAppend(hostForm, "Device Model:", uiControl(uiNewLabel(model)), 0)
    uiFormAppend(hostForm, "Hostname:", uiControl(uiNewLabel(hostname)), 0)
    uiFormAppend(hostForm, "Username:", uiControl(uiNewLabel(username)), 0)
    uiFormAppend(hostForm, "System Uptime:", uiControl(uiNewLabel(uptime)), 0)

    uiBoxAppend(hostBox, uiControl(hostForm), 1)
    uiGroupSetChild(hostGroup, uiControl(hostBox))
    uiBoxAppend(sysInfoPage, uiControl(hostGroup), 0)
    
    // Add visual separator between sections
    uiBoxAppend(sysInfoPage, uiControl(uiNewVerticalSeparator()), 0)

    // Operating System Group - OS details and architecture
    osGroup = uiNewGroup("Operating System Information")
    uiGroupSetMargined(osGroup, 1)
    osBox = uiNewVerticalBox()
    uiBoxSetPadded(osBox, 1)

    osForm = uiNewForm()
    uiFormSetPadded(osForm, 1)
    uiFormAppend(osForm, "Operating System:", uiControl(uiNewLabel(osName)), 0)
    uiFormAppend(osForm, "Architecture:", uiControl(uiNewLabel(arch)), 0)
    uiFormAppend(osForm, "Kernel Version:", uiControl(uiNewLabel(kernelVer)), 0)

    uiBoxAppend(osBox, uiControl(osForm), 1)
    uiGroupSetChild(osGroup, uiControl(osBox))
    uiBoxAppend(sysInfoPage, uiControl(osGroup), 0)

    uiBoxAppend(sysInfoPage, uiControl(uiNewVerticalSeparator()), 0)

    // Environment Group - Shell and package information
    envGroup = uiNewGroup("Environment Information")
    uiGroupSetMargined(envGroup, 1)
    envBox = uiNewVerticalBox()
    uiBoxSetPadded(envBox, 1)

    envForm = uiNewForm()
    uiFormSetPadded(envForm, 1)
    uiFormAppend(envForm, "Shell:", uiControl(uiNewLabel(shell)), 0)
    uiFormAppend(envForm, "Installed Packages:", uiControl(uiNewLabel(string(pcount))), 0)

    uiBoxAppend(envBox, uiControl(envForm), 1)
    uiGroupSetChild(envGroup, uiControl(envBox))
    uiBoxAppend(sysInfoPage, uiControl(envGroup), 0)

    // ===========================================
    // HARDWARE INFORMATION TAB
    // ===========================================
    
    hwPage = uiNewVerticalBox()
    uiBoxSetPadded(hwPage, 1)
    uiTabAppend(mainTab, "🔧 Hardware", uiControl(hwPage))

    // CPU Group - Processor information with temperature monitoring
    cpuGroup = uiNewGroup("Processor Information")
    uiGroupSetMargined(cpuGroup, 1)
    cpuBox = uiNewVerticalBox()
    uiBoxSetPadded(cpuBox, 1)

    // CPU temperature detection (Unix systems only, not available in VMs)
    cpuTemp = "Not available"
    if (isUnix() && !sys.isVM()) {
        try {
            tempValue = sys.cpu()[:temp]
            if (!isNull(tempValue)) {
                cpuTemp = string(tempValue) + "°C"
            }
        catch
            cpuTemp = "Error reading temperature"
        }
    }

    // CPU information form with detailed specifications
    cpuForm = uiNewForm()
    uiFormSetPadded(cpuForm, 1)
    uiBoxAppend(cpuBox, uiControl(cpuForm), 0)
    uiFormAppend(cpuForm, "CPU Model:", uiControl(uiNewLabel(cpuModel)), 0)
    uiFormAppend(cpuForm, "Physical Cores:", uiControl(uiNewLabel(cpuCores)), 0)
    uiFormAppend(cpuForm, "Logical Threads:", uiControl(uiNewLabel(cpuThreads)), 0)
    uiFormAppend(cpuForm, "Current Usage:", uiControl(uiNewLabel(cpuUsage)), 0)
    
    // Show temperature only if available (Unix systems, non-VM)
    if (isUnix() && !sys.isVM()) {
        uiFormAppend(cpuForm, "Temperature:", uiControl(uiNewLabel(cpuTemp)), 0)
    }

    uiGroupSetChild(cpuGroup, uiControl(cpuBox))
    uiBoxAppend(hwPage, uiControl(cpuGroup), 0)

    uiBoxAppend(hwPage, uiControl(uiNewVerticalSeparator()), 0)

    // Memory Group - RAM and swap information
    memGroup = uiNewGroup("Memory Information")
    uiGroupSetMargined(memGroup, 1)
    memBox = uiNewVerticalBox()
    uiBoxSetPadded(memBox, 1)

    // Memory statistics form
    memForm = uiNewForm()
    uiFormSetPadded(memForm, 1)
    uiBoxAppend(memBox, uiControl(memForm), 0)
    uiFormAppend(memForm, "Total RAM:", uiControl(uiNewLabel(formatMemory(totalRam))), 0)
    uiFormAppend(memForm, "Used RAM:", uiControl(uiNewLabel(formatMemory(usedRam))), 0)
    uiFormAppend(memForm, "Free RAM:", uiControl(uiNewLabel(formatMemory(freeRam))), 0)
    
    // Display swap/pagefile based on operating system
    if (isWindows()) {
        swapLabel = "Pagefile:"
    else
        swapLabel = "Swap:"
    }
    uiFormAppend(memForm, swapLabel, uiControl(uiNewLabel(formatMemory(swapRam))), 0)

    uiGroupSetChild(memGroup, uiControl(memBox))
    uiBoxAppend(hwPage, uiControl(memGroup), 0)

    // GPU Group - Graphics hardware information
    gpuGroup = uiNewGroup("Graphics Information")
    uiGroupSetMargined(gpuGroup, 1)
    gpuBox = uiNewVerticalBox()
    uiBoxSetPadded(gpuBox, 1)

    // Handle GPU information with error checking
    gpu = "Not available"
    if (!isNull(gpuInfo)) {
        try {
            gpu = string(gpuInfo)
        catch
            gpu = "Error retrieving GPU information"
        }
    }

    // GPU information form
    gpuForm = uiNewForm()
    uiFormSetPadded(gpuForm, 1)
    uiFormAppend(gpuForm, "Graphics Card:", uiControl(uiNewLabel(gpu)), 0)

    uiBoxAppend(gpuBox, uiControl(gpuForm), 1)
    uiGroupSetChild(gpuGroup, uiControl(gpuBox))
    uiBoxAppend(hwPage, uiControl(gpuGroup), 0)

    // ===========================================
    // STORAGE INFORMATION TAB
    // ===========================================
    
    storagePage = uiNewVerticalBox()
    uiBoxSetPadded(storagePage, 1)
    uiTabAppend(mainTab, "💾 Storage", uiControl(storagePage))

    // Storage Disks Group - Physical storage devices
    disksGroup = uiNewGroup("Physical Storage Devices")
    uiGroupSetMargined(disksGroup, 1)
    disksBox = uiNewVerticalBox()
    uiBoxSetPadded(disksBox, 1)

    if (isList(disks) && len(disks) > 0) {
        diskForm = uiNewForm()
        uiFormSetPadded(diskForm, 1)
        uiBoxAppend(disksBox, uiControl(diskForm), 0)
        
        for disk in disks {
            if (isList(disk)) {
                diskName = disk[:name]
                diskSize = disk[:size]
                uiFormAppend(diskForm, diskName + ":", uiControl(uiNewLabel("Capacity: " + diskSize)), 0)
            }
        }
    else
        uiBoxAppend(disksBox, uiControl(uiNewLabel("No physical storage devices detected")), 0)
    }

    uiGroupSetChild(disksGroup, uiControl(disksBox))
    uiBoxAppend(storagePage, uiControl(disksGroup), 0)
    uiBoxAppend(storagePage, uiControl(uiNewVerticalSeparator()), 0)

    // Storage Partitions Group - Mounted volumes and partitions
    partsGroup = uiNewGroup("Mounted Storage Partitions")
    uiGroupSetMargined(partsGroup, 1)
    partsBox = uiNewVerticalBox()
    uiBoxSetPadded(partsBox, 1)

    if (isList(parts) && len(parts) > 0) {
        partForm = uiNewForm()
        uiFormSetPadded(partForm, 1)
        uiBoxAppend(partsBox, uiControl(partForm), 0)
        
        for part in parts {
            if (isList(part)) {
                partName = part[:name]
                partSize = part[:size]
                partUsed = part[:used]
                partFree = part[:free]
                partInfo = "Total: " + partSize + " | Used: " + partUsed + " | Free: " + partFree
                uiFormAppend(partForm, partName + ":", uiControl(uiNewLabel(partInfo)), 0)
            }
        }
    else
        uiBoxAppend(partsBox, uiControl(uiNewLabel("No mounted partitions detected")), 0)
    }

    uiGroupSetChild(partsGroup, uiControl(partsBox))
    uiBoxAppend(storagePage, uiControl(partsGroup), 0)

    // ===========================================
    // NETWORK INFORMATION TAB
    // ===========================================
    
    networkPage = uiNewVerticalBox()
    uiBoxSetPadded(networkPage, 1)
    uiTabAppend(mainTab, "🌐 Network", uiControl(networkPage))

    // Network Interfaces Group - Active network connections
    netGroup = uiNewGroup("Active Network Interfaces")
    uiGroupSetMargined(netGroup, 1)
    netBox = uiNewVerticalBox()
    uiBoxSetPadded(netBox, 1)

    if (isList(networkInfo) && len(networkInfo) > 0) {
        netForm = uiNewForm()
        uiFormSetPadded(netForm, 1)
        uiBoxAppend(netBox, uiControl(netForm), 0)
        
        for interface in networkInfo {
            if (isList(interface)) {
                interfaceName = interface[:name]
                interfaceIP = interface[:ip]
                interfaceStatus = interface[:status]
                
                // Format network interface information
                networkDetails = "IP: " + interfaceIP + " | Status: " + interfaceStatus
                uiFormAppend(netForm, interfaceName + ":", uiControl(uiNewLabel(networkDetails)), 0)
            }
        }
    else
        uiBoxAppend(netBox, uiControl(uiNewLabel("No active network interfaces found")), 0)
    }

    uiGroupSetChild(netGroup, uiControl(netBox))
    uiBoxAppend(networkPage, uiControl(netGroup), 0)

    // ===========================================
    // APPLICATION FOOTER
    // ===========================================
    
    // Footer with application credits and GitHub information
    footerGroup = uiNewGroup("")
    footerBox = uiNewHorizontalBox()
    uiBoxSetPadded(footerBox, 1)
    creditsLabel = uiNewLabel("© 2025 RingFetch GUI | Created by ysdragon")
    githubLabel = uiNewLabel("github.com/ysdragon/SysInfo")
    uiBoxAppend(footerBox, uiControl(creditsLabel), 1)
    uiBoxAppend(footerBox, uiControl(githubLabel), 0)
    uiGroupSetChild(footerGroup, uiControl(footerBox))
    uiBoxAppend(mainBox, uiControl(footerGroup), 0)

    // ===========================================
    // APPLICATION STARTUP
    // ===========================================
    
    // Display the window and start the GUI event loop
    uiControlShow(uiControl(mainWindow))
    uiMain()
}

// ===========================================
// HELPER FUNCTIONS
// ===========================================

// Helper function to format memory values with size formatting
func formatMemory(value) {
    // Check if value is not a number and convert it to a number
    if (!isNumber(value)) {
        value = number(value)
    }

    // Format memory size in KB, MB, or GB based on value
    if (value < 1) {
        return string(value * 1024) + " KB"
    elseif (value < 1024)
        return string(value) + " MB"
    else
        return string(value / 1024) + " GB"
    }
}

// Window closing event handler
// Properly shuts down the GUI application
func onClosing() {
    uiQuit()
}