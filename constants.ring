/*
    Author: ysdragon (https://github.com/ysdragon)
*/

// PowerShell Script for Windows
PS_SCRIPT = `$MODEL = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
$CPU_INFO = (Get-CimInstance -Query 'SELECT Name, NumberOfCores, NumberOfLogicalProcessors FROM Win32_Processor')
$CPU_USAGE = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue
$CPU_MODELS = @()
$CPU_COUNT = 0
$TOTAL_CORES = 0
$TOTAL_THREADS = 0
$CPUS = @()

foreach ($CPU in $CPU_INFO) {
    $CPU_MODEL = $CPU.Name.Trim()
    $TOTAL_CORES += $CPU.NumberOfCores
    $TOTAL_THREADS += $CPU.NumberOfLogicalProcessors
    $CPU_MODELS += $CPU_MODEL
    $CPU_COUNT++
    
    $CPUS += @{
        number = $CPU_COUNT
        model = $CPU_MODEL
        cores = $CPU.NumberOfCores
        threads = $CPU.NumberOfLogicalProcessors
    }
}

$CPU = @{
    count = $CPU_COUNT
    model = $CPU_MODELS[0]
    cores = $TOTAL_CORES
    threads = $TOTAL_THREADS
    usage = [math]::round($CPU_USAGE, 2)
    cpus = $CPUS
}
$GPU_INFO = (Get-CimInstance -Query 'SELECT Caption FROM Win32_VideoController')
$GPUs = @()
foreach ($GPU in $GPU_INFO) {
    $GPUs += @{
        name = $GPU.Caption
    }
}
$OS = (Get-CimInstance -Query 'SELECT Caption, Version, FreePhysicalMemory FROM Win32_OperatingSystem')
$TOTAL_RAM = [math]::round((Get-CimInstance -Query 'SELECT Capacity FROM Win32_PhysicalMemory' | Measure-Object -Property Capacity -Sum).Sum / 1MB, 2)
$PAGE_FILES = Get-CimInstance -Class Win32_PageFileUsage
$FREE_RAM = [math]::round($OS.FreePhysicalMemory / 1KB, 2)
$USED_RAM = [math]::round($TOTAL_RAM - $FREE_RAM, 2)
$TOTAL_SWAP = [math]::round((($PAGE_FILES | Measure-Object -Property AllocatedBaseSize -Sum).Sum), 2)
$RAM = @{
    size = $TOTAL_RAM
    used = $USED_RAM
    free = $FREE_RAM
    swap = $TOTAL_SWAP
}
$DISKS_RAW = Get-CimInstance -Query 'SELECT Size, DeviceID, Model FROM Win32_DiskDrive'
$DISKS = @()
foreach ($DISK in $DISKS_RAW) {
    $DISKS += @{
        name = $DISK.Model
        size = [math]::Round($DISK.Size / 1KB, 0)
    }
}
$PARTS_RAW = (Get-CimInstance -Query 'SELECT Size, FreeSpace, Caption FROM Win32_LogicalDisk WHERE DriveType=3')
$PARTS = @()
foreach ($PART in $PARTS_RAW) {
    $usedBytes = $PART.Size - $PART.FreeSpace
    $PARTS += @{
        name = $PART.Caption
        size = [math]::Round($PART.Size / 1KB, 0)
        used = [math]::Round($usedBytes / 1KB, 0)
        free = [math]::Round($PART.FreeSpace / 1KB, 0)
    }
}
$PCOUNT = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Measure-Object).Count
$SHELL_NAME = 'PowerShell'
$SHELL_VERSION = $PSVersionTable.PSVersion.ToString()
$SHELL = @{
    name = $SHELL_NAME
    version = $SHELL_VERSION
}
$NETWORK_RAW = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.IPAddress }
$NETWORK = @()
foreach ($NET in $NETWORK_RAW) {
    if ($NET.IPAddress -and $NET.IPAddress.Count -gt 0) {
        $NETWORK += @{
            name = $NET.Description
            ip = $NET.IPAddress[0]
            status = "up"
        }
    }
}
$isVM = [int]((Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer -match 'Microsoft Corporation|VMware|Xen|KVM|VirtualBox|QEMU')
$Result = @{
    model = $MODEL
    cpu = $CPU
    gpu = $GPUs
    ram = $RAM
    os = $OS.Caption
    version = $OS.Version
    disks = $DISKS
    parts = $PARTS
    pcount = $PCOUNT
    shell = $SHELL
    network = $NETWORK
    isVM = $isVM
}
Write-Output (ConvertTo-Json $Result -Depth 4)`

// Time units
tUnits = [
    [86400, "day", :days],
    [3600, "hour", :hours],
    [60, "minute", :minutes],
    [1, "second", :seconds]
]

// Linux Package Managers
pManagers = [
    :dpkg = [
        :supported = [
            "debian", "ubuntu", "devuan", "rhino", "linuxmint", "osmc", "antix", "pop", "popos", "elementary", "vanilla", "sparky", "kali", "kubuntu", "deepin", "tails", "voyager", "damnsmall", "q4os", "lubuntu", "parrot", "endless", "wattos", "watt", "qubes", "qubesos", "xubuntu", "bodhi", "gnoppix", "relianoid", "av", "avlinux", "pure", "pureos", "bros", "br", "spiral", "syslinux", "syslinuxos", "mate", "ubuntumate", "neptune", "lxle", "makulu", "emmabuntüs", "bunsenLabs", "kodachi", "nitrux", "aosc"
        ],
        :cmd = "dpkg-query -f '${binary:Package}\n' -W | wc -l",
        :name = "dpkg"
    ],
    :dnf = [
        :supported = [
            "rhel", "fedora", "centos", "almalinux", "rockylinux", "mageia", "openmandriva", "ultramarine", "redhat", "oracle", "openEuler", "ol", "amzn", "anolis"
        ],
        :cmd = "rpm -qa | wc -l",
        :name = "rpm"
    ],
    :zypper = [
        :supported = [
            "opensuse", "opensuse-tumbleweed", "opensuse-leap", "regata"
        ],
        :cmd = "zypper se --installed-only | wc -l",
        :name = "zypper"
    ],
    :pacman = [
        :supported = [
            "arch", "archarm", "artix", "endeavouros", "endeavour", "manjaro", "cachyos", "cachy", "garuda", "arco", "arcolinux", "archcraft", "bluestar", "sdesk", "biglinux", "big", "reborn", "rebornos", "blendos", "blend", "mabox", "athena"
        ],
        :cmd = "pacman -Q | wc -l",
        :name = "pacman"
    ],
    :emerge = [
        :supported = [
            "gentoo", "fentoo", "calculate"
        ],
        :cmd = "qlist -I | wc -l",
        :name = "emerge"
    ],
    :pkg = [
        :supported = [
            "freebsd", "openbsd", "ghostbsd", "netbsd"
        ],
        :cmd = "pkg info | wc -l | tr -d ' '",
        :name = "pkg"
    ],
    :xbps = [
        :supported = [
            "void", "gabee", "gabeeos", "agarim", "agarimos"
        ],
        :cmd = "xbps-query -l | wc -l",
        :name = "xbps"
    ],
    :nix_env = [
        :supported = [
            "nixos"
        ],
        :cmd = "nix-store -q --requisites /run/current-system/sw | wc -l",
        :name = "nix_env"
    ],
    :apk = [
        :supported = [
            "alpine", "chimera"
        ],
        :cmd = "apk list --installed | wc -l",
        :name = "apk"
    ],
    :slackpkg = [
        :supported = [
            "slackware", "porteus", "porteux", "absolute"
        ],
        :cmd = "ls /var/log/packages | wc -l",
        :name = "slackpkg"
    ],
    :brew = [
        :supported = [
            "any"
        ],
        :cmd = "brew list --cellar | wc -l",
        :name = "brew"
    ]
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

// Storage parts to filter out (temporary filesystems, virtual filesystems, etc.)
filteredStorageParts = [
    "tmpfs",
    "devtmpfs", 
    "dev",
    "run",
    "shm",
    "proc",
    "sys",
    "sysfs",
    "devpts",
    "securityfs",
    "debugfs",
    "mqueue",
    "hugetlbfs",
    "efivarfs",
    "binfmt_misc",
    "autofs",
    "configfs",
    "fusectl",
    "pstore",
    "cgroup",
    "cgroup2",
    "none",
    "overlay",
    "squashfs"
]