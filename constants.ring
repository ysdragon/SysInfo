/*
    Author: ysdragon (https://github.com/ysdragon)
*/

// PowerShell Script for Windows
PS_SCRIPT = `$CPU_INFO = (Get-CimInstance -Query 'SELECT Name, NumberOfCores, NumberOfLogicalProcessors FROM Win32_Processor')
$CPU_USAGE = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
$CPU_MODELS = @()
foreach ($CPU in $CPU_INFO) {
    $CPU_MODEL = $CPU.Name.Trim()
    $TOTAL_CORES += $CPU.NumberOfCores
    $TOTAL_THREADS += $CPU.NumberOfLogicalProcessors
    $CPU_MODELS += $CPU_MODEL
    $CPU_COUNT++
}
$CPU = @{
    cores = $TOTAL_CORES
    count = $CPU_COUNT
    model = [string]::Join(", ", $CPU_MODELS)
    threads = $TOTAL_THREADS
    usage = [math]::round($CPU_USAGE, 2)
}
$GPU_INFO = (Get-CimInstance -Query 'SELECT Caption FROM Win32_VideoController')
$GPUs = @()
foreach ($GPU in $GPU_INFO) {
    $GPUs += @{
        name = $GPU.Caption
    }
}
$OS = (Get-CimInstance -Query 'SELECT Caption, Version, FreePhysicalMemory FROM Win32_OperatingSystem')
$TOTAL_RAM = [math]::round((Get-CimInstance -Query 'SELECT Capacity FROM Win32_PhysicalMemory' | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
$PAGE_FILES = Get-CimInstance -Class Win32_PageFileUsage
$FREE_RAM = [math]::round($OS.FreePhysicalMemory / 1MB, 2)
$USED_RAM = [math]::round($TOTAL_RAM - $FREE_RAM, 2)
$TOTAL_SWAP = [math]::round((($PAGE_FILES | Measure-Object -Property AllocatedBaseSize -Sum).Sum) / 1024, 2)
$RAM = @{
    size = $TOTAL_RAM.ToString() + 'G'
    used = $USED_RAM.ToString() + 'G'
    free = $FREE_RAM.ToString() + 'G'
    swap = $TOTAL_SWAP.ToString() + 'G'
}
$DISKS_RAW = Get-CimInstance -Query 'SELECT Size, DeviceID, Model FROM Win32_DiskDrive'
$DISKS = @()
foreach ($DISK in $DISKS_RAW) {
    $DISKS += @{
        name = $DISK.Model
        size = [math]::round($DISK.Size / 1GB, 2).ToString() + 'G'
    }
}
$PARTS_RAW = (Get-CimInstance -Query 'SELECT Size, FreeSpace, Caption FROM Win32_LogicalDisk WHERE DriveType=3')
$PARTS = @()
foreach ($PART in $PARTS_RAW) {
    $PARTS += @{
        name = $PART.Caption
        size = [math]::round($PART.Size / 1GB, 2).ToString() + 'G'
        used = ([math]::round($PART.Size / 1GB, 2) - [math]::round($PART.FreeSpace / 1GB, 2)).ToString() + 'G'
        free = [math]::round($PART.FreeSpace / 1GB, 2).ToString() + 'G'
    }
}
$PCOUNT = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Measure-Object).Count
$SHELL_NAME = 'PowerShell'
$SHELL_VERSION = $PSVersionTable.PSVersion.ToString()
$SHELL = @{
    name = $SHELL_NAME
    version = $SHELL_VERSION
}
$isVM = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer -match 'Microsoft Corporation|VMware|Xen|KVM|VirtualBox|QEMU'
$Result = @{
    cpu = $CPU
    gpu = $GPUs
    ram = $RAM
    os = $OS.Caption
    version = $OS.Version
    disks = $DISKS
    parts = $PARTS
    pcount = $PCOUNT
    shell = $SHELL
    isVM = $isVM
}
Write-Output (ConvertTo-Json $Result)`

// Time units
tUnits = [
    [86400, "day", :days],
    [3600, "hour", :hours],
    [60, "minute", :minutes],
    [1, "second", :seconds]
]

// Linux Package Managers
pManagers = [
    :dpkg = [:supported = ["debian", "ubuntu", "devuan", "rhino", "linuxmint", "osmc", "antix", "pop", "popos", "elementary", "vanilla", "sparky", "kali", "kubuntu", "deepin", "tails", "voyager", "damnsmall", "q4os", "lubuntu", "parrot", "endless", "wattos", "watt", "qubes", "qubesos", "xubuntu", "bodhi", "gnoppix", "relianoid", "av", "avlinux", "pure", "pureos", "bros", "br", "spiral", "syslinux", "syslinuxos", "mate", "ubuntumate", "neptune", "lxle", "makulu", "emmabuntüs", "bunsenLabs", "kodachi", "nitrux"], :cmd = "dpkg-query -f '${binary:Package}\n' -W | wc -l", :name = "dpkg"],
    :dnf =  [:supported = ["fedora", "centos", "almalinux", "rockylinux", "mageia", "openmandriva", "ultramarine", "redhat", "oracle", "openEuler", "ol", "amzn"], :cmd = "rpm -qa | wc -l", :name = "rpm"],
    :zypper = [:supported = ["opensuse", "opensuse-tumbleweed", "opensuse-leap", "regata"], :cmd = "zypper se --installed-only | wc -l", :name = "zypper"],
    :pacman = [:supported = ["arch", "archarm", "artix", "endeavouros", "endeavour", "manjaro", "cachyos", "cachy", "garuda", "arco", "arcolinux", "archcraft", "bluestar", "sdesk", "biglinux", "big", "reborn", "rebornos", "blendos", "blend", "mabox", "athena"], :cmd = "pacman -Q | wc -l", :name = "pacman"],
    :emerge = [:supported = ["gentoo", "fentoo", "calculate"], :cmd = "qlist -I | wc -l", :name = "emerge"],
    :pkg = [:supported = ["freebsd", "openbsd", "ghostbsd", "netbsd"], :cmd = "pkg info | wc -l | tr -d ' '", :name = "pkg"],
    :xbps = [:supported = ["void", "gabee", "gabeeos", "agarim", "agarimos"], :cmd = "xbps-query -l | wc -l", :name = "xbps"],
    :nix_env = [:supported = ["nix"], :cmd = "nix-store -q --requisites /run/current-system/sw | wc -l", :name = "nix_env"],
    :apk = [:supported = ["alpine", "chimera"], :cmd = "apk list --installed | wc -l", :name = "apk"],
    :slackpkg = [:supported = ["slackware", "porteus", "porteux", "absolute"], :cmd = "ls /var/log/packages | wc -l", :name = "slackpkg"],
    :brew = [:supported = ["any"], :cmd = "brew list --cellar | wc -l", :name = "brew"]
]

// Virtualization indicators list 
virtIndicators = [
    "KVM",
    "QEMU",
    "VMware",
    "VMW",
    "innotek",
    "Xen",
    "Bochs",
    "Parallels",
    "BHYVE",
    "OpenStack",
    "KubeVirt",
    "Amazon EC2",
    "Oracle Corporation",
    "Hyper-V",
    "Apple Virtualization",
    "Google Compute Engine"
]
