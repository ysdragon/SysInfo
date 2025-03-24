/*
    Author: ysdragon (https://github.com/ysdragon)
    GUI Example using LibUI and SysInfo package
*/

load "libui.ring"
load "SysInfo.ring"

func main() {
    // Create a new instance of the SysInfo class
    sys = new SysInfo

    // Retrieve system info
    hostname = sys.hostname()
    username = sys.username()
    shell = sys.shell()[:name] + " " + sys.shell()[:version]
    osName = sys.os()[:name]
    arch = sys.arch()
    kernelVer = sys.version()
    pcount = sys.pCount()
    uptime = sys.sysUptime([])

    // Retrieve CPU info
    cpuModel = sys.cpu()[:model]
    cpuCores = string(sys.cpu()[:cores])
    cpuThreads = string(sys.cpu()[:threads])
    cpuUsage = string(sys.cpu()[:usage]) + "%"

    // Retrieve memory info
    totalRam = sys.ram()[:size]
    usedRam = sys.ram()[:used]
    freeRam = sys.ram()[:free]
    swapRam = sys.ram()[:swap]

    // Retrieve GPU info
    gpuInfo = sys.gpu()

    // Retrieve storage disks
    disks = sys.storageDisks()

    // Retrieve storage parts
    parts = sys.storageParts()

    // Create the main window
    mainWindow = uiNewWindow("RingFetch GUI", 570, 450, 0)
    uiWindowOnClosing(mainWindow, "onClosing()")
    uiWindowSetMargined(mainWindow, 1)

    // Main container
    mainBox = uiNewVerticalBox()
    uiBoxSetPadded(mainBox, 1)
    uiWindowSetChild(mainWindow, uiControl(mainBox))

    mainTab = uiNewTab()
    uiBoxAppend(mainBox, uiControl(mainTab), 1)

    // System Overview tab
    sysInfoPage = uiNewVerticalBox()
    uiBoxSetPadded(sysInfoPage, 1)
    uiTabAppend(mainTab, "💻 System", uiControl(sysInfoPage))

    // Host Information Group
    hostGroup = uiNewGroup("Host Information")
    uiGroupSetMargined(hostGroup, 1)
    hostBox = uiNewVerticalBox()
    uiBoxSetPadded(hostBox, 1)

    hostForm = uiNewForm()
    uiFormSetPadded(hostForm, 1)
    uiFormAppend(hostForm, "Hostname:", uiControl(uiNewLabel(hostname)), 0)
    uiFormAppend(hostForm, "Username:", uiControl(uiNewLabel(username)), 0)
    uiFormAppend(hostForm, "Uptime:", uiControl(uiNewLabel(uptime)), 0)

    uiBoxAppend(hostBox, uiControl(hostForm), 1)
    uiGroupSetChild(hostGroup, uiControl(hostBox))
    uiBoxAppend(sysInfoPage, uiControl(hostGroup), 0)
    uiBoxAppend(sysInfoPage, uiControl(uiNewLabel("")), 0)

    // Operating System Group
    osGroup = uiNewGroup("Operating System")
    uiGroupSetMargined(osGroup, 1)
    osBox = uiNewVerticalBox()
    uiBoxSetPadded(osBox, 1)

    osForm = uiNewForm()
    uiFormSetPadded(osForm, 1)
    uiFormAppend(osForm, "OS Name:", uiControl(uiNewLabel(osName)), 0)
    uiFormAppend(osForm, "Architecture:", uiControl(uiNewLabel(arch)), 0)
    uiFormAppend(osForm, "Kernel:", uiControl(uiNewLabel(kernelVer)), 0)

    uiBoxAppend(osBox, uiControl(osForm), 1)
    uiGroupSetChild(osGroup, uiControl(osBox))
    uiBoxAppend(sysInfoPage, uiControl(osGroup), 0)

    uiBoxAppend(sysInfoPage, uiControl(uiNewLabel("")), 0)

    // Environment Group
    envGroup = uiNewGroup("Environment")
    uiGroupSetMargined(envGroup, 1)
    envBox = uiNewVerticalBox()
    uiBoxSetPadded(envBox, 1)

    envForm = uiNewForm()
    uiFormSetPadded(envForm, 1)
    uiFormAppend(envForm, "Shell:", uiControl(uiNewLabel(shell)), 0)
    uiFormAppend(envForm, "Packages:", uiControl(uiNewLabel(string(pcount))), 0)

    uiBoxAppend(envBox, uiControl(envForm), 1)
    uiGroupSetChild(envGroup, uiControl(envBox))
    uiBoxAppend(sysInfoPage, uiControl(envGroup), 0)

    // Hardware tab
    hwPage = uiNewVerticalBox()
    uiBoxSetPadded(hwPage, 1)
    uiTabAppend(mainTab, "🔧 Hardware", uiControl(hwPage))

    // CPU Group
    cpuGroup = uiNewGroup("Processor Information")
    uiGroupSetMargined(cpuGroup, 1)
    cpuBox = uiNewVerticalBox()
    uiBoxSetPadded(cpuBox, 1)

    if (isUnix() && !sys.isVM()) {
        tempValue = sys.cpu()[:temp]
        if (isNull(tempValue)) {
            cpuTemp = "Not available"
        else
            try {
                cpuTemp = "" + tempValue + "°C"
            catch
                cpuTemp = "Not available" + cCatchError
            }
        }
    else
        cpuTemp = "Not available"
    }

    // CPU information form
    cpuForm = uiNewForm()
    uiFormSetPadded(cpuForm, 1)
    uiBoxAppend(cpuBox, uiControl(cpuForm), 0)
    uiFormAppend(cpuForm, "Model:", uiControl(uiNewLabel(cpuModel)), 0)
    uiFormAppend(cpuForm, "Cores:", uiControl(uiNewLabel(cpuCores)), 0)
    uiFormAppend(cpuForm, "Threads:", uiControl(uiNewLabel(cpuThreads)), 0)
    uiFormAppend(cpuForm, "Usage:", uiControl(uiNewLabel(cpuUsage)), 0)

    if (isUnix() && !sys.isVM()) {
        uiFormAppend(cpuForm, "Temperature:", uiControl(uiNewLabel(cpuTemp)), 0)
    }

    uiGroupSetChild(cpuGroup, uiControl(cpuBox))
    uiBoxAppend(hwPage, uiControl(cpuGroup), 0)

    uiBoxAppend(hwPage, uiControl(uiNewLabel("")), 0)

    // Memory Group
    memGroup = uiNewGroup("Memory Status")
    uiGroupSetMargined(memGroup, 1)
    memBox = uiNewVerticalBox()
    uiBoxSetPadded(memBox, 1)

    // Add memory info to the form
    memForm = uiNewForm()
    uiFormSetPadded(memForm, 1)
    uiBoxAppend(memBox, uiControl(memForm), 0)
    uiFormAppend(memForm, "Total RAM:", uiControl(uiNewLabel(string(totalRam))), 0)
    uiFormAppend(memForm, "Used RAM:", uiControl(uiNewLabel(string(usedRam))), 0)
    uiFormAppend(memForm, "Free RAM:", uiControl(uiNewLabel(string(freeRam))), 0)
    uiFormAppend(memForm, "Swap:", uiControl(uiNewLabel(string(swapRam))), 0)

    uiGroupSetChild(memGroup, uiControl(memBox))

    uiBoxAppend(hwPage, uiControl(memGroup), 0)

    // GPU Group
    gpuGroup = uiNewGroup("Graphics Information")
    uiGroupSetMargined(gpuGroup, 1)
    gpuBox = uiNewVerticalBox()
    uiBoxSetPadded(gpuBox, 1)

    if (isNull(gpuInfo)) {
        gpu = "Not available"
    else
        try {
            gpu = string(gpuInfo)
        catch
            gpu = "Not available" + cCatchError
        }
    }

    // Add GPU info to the form
    gpuForm = uiNewForm()
    uiFormSetPadded(gpuForm, 1)
    uiFormAppend(gpuForm, "Model:", uiControl(uiNewLabel(gpu)), 0)

    uiBoxAppend(gpuBox, uiControl(gpuForm), 1)
    uiGroupSetChild(gpuGroup, uiControl(gpuBox))
    uiBoxAppend(hwPage, uiControl(gpuGroup), 0)
    uiBoxAppend(hwPage, uiControl(uiNewLabel("")), 0)

    storagePage = uiNewVerticalBox()
    uiBoxSetPadded(storagePage, 1)
    uiTabAppend(mainTab, "💾 Storage", uiControl(storagePage))

    // Storage Disks Group
    disksGroup = uiNewGroup("Storage Disks")
    uiGroupSetMargined(disksGroup, 1)
    disksBox = uiNewVerticalBox()
    uiBoxSetPadded(disksBox, 1)

    if (len(disks) > 0) {
        diskForm = uiNewForm()
        uiFormSetPadded(diskForm, 1)
        uiBoxAppend(disksBox, uiControl(diskForm), 0)
        
        for disk in disks {
            diskName = disk[:name]
            diskSize = disk[:size]
            uiFormAppend(diskForm, diskName + ":", uiControl(uiNewLabel("Size: " + diskSize)), 0)
        }
    else
        uiBoxAppend(disksBox, uiControl(uiNewLabel("No storage disks found")), 0)
    }

    uiGroupSetChild(disksGroup, uiControl(disksBox))
    uiBoxAppend(storagePage, uiControl(disksGroup), 0)
    uiBoxAppend(storagePage, uiControl(uiNewLabel("")), 0)

    // Storage Partitions Group
    partsGroup = uiNewGroup("Storage Partitions")
    uiGroupSetMargined(partsGroup, 1)
    partsBox = uiNewVerticalBox()
    uiBoxSetPadded(partsBox, 1)

    if (len(parts) > 0) {
        partForm = uiNewForm()
        uiFormSetPadded(partForm, 1)
        uiBoxAppend(partsBox, uiControl(partForm), 0)
        
        for part in parts {
            partName = part[:name]
            partSize = "Size: " + part[:size]
            partUsed = "Used: " + part[:used]
            partFree = "Free: " + part[:free]
            uiFormAppend(partForm, partName + ":", uiControl(uiNewLabel(partSize + ", " + partUsed + ", " + partFree)), 0)
        }
    else
        uiBoxAppend(partsBox, uiControl(uiNewLabel("No partitions found")), 0)
    }

    uiGroupSetChild(partsGroup, uiControl(partsBox))
    uiBoxAppend(storagePage, uiControl(partsGroup), 0)
    uiBoxAppend(storagePage, uiControl(uiNewLabel("")), 0)

    // Footer
    footerGroup = uiNewGroup("")
    footerBox = uiNewHorizontalBox()
    uiBoxSetPadded(footerBox, 1)
    creditsLabel = uiNewLabel("© RingFetch GUI | Created by DraGoN")
    githubLabel = uiNewLabel("github.com/ysdragon")
    uiBoxAppend(footerBox, uiControl(creditsLabel), 1)
    uiBoxAppend(footerBox, uiControl(githubLabel), 0)
    uiGroupSetChild(footerGroup, uiControl(footerBox))
    uiBoxAppend(mainBox, uiControl(footerGroup), 0)

    // Show the window and start the application
    uiControlShow(uiControl(mainWindow))
    uiMain()
}

// Function to handle window quit event
func onClosing() {
    uiQuit()
}