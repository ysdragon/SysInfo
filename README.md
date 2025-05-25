<div align="center">

# SysInfo

A comprehensive system information retrieval package for [Ring](https://ring-lang.net/) programming language

[![Ring](https://img.shields.io/badge/Made%20with-Ring-2D54CB)](https://ring-lang.net/)

![GitHub release](https://img.shields.io/github/v/release/ysdragon/SysInfo)
![GitHub](https://img.shields.io/github/license/ysdragon/SysInfo)
</div>

## Overview

SysInfo is a powerful Ring package that provides easy access to essential system information across different operating systems.

## Features

### Core System Info
- System hostname and username
- OS name and kernel version
- CPU model, cores, and usage metrics
- RAM capacity and usage statistics
- GPU detection and details
- Storage devices and partition info
- System uptime tracking
- Virtual machine detection

### Environment Details
- Shell identification and version
- Terminal emulator detection
- Package count and manager info
- System architecture detection

### Cross-Platform Support
- Linux/Unix/Windows support


## Installation

### Using Ring Package Manager (`ringpm`)

#### From the RingPM Registry
```bash
# Refresh the registry first
ringpm refresh

# Install the package
ringpm install SysInfo
```

#### From This Repository
```bash
ringpm install SysInfo from ysdragon
```

To update to the latest version:
```bash
ringpm update SysInfo
```

## Usage

```ring
load "SysInfo.ring"

// Create a new SysInfo instance
sys = new SysInfo

// Get basic system information
? "OS: " + sys.os()[:name]
? "Hostname: " + sys.hostname()
? "CPU: " + sys.cpu()[:model]
? "Total RAM: " + (sys.ram()[:size] / 1024) + " GB"
```

For detailed API documentation, please refer to the [SysInfo Library Documentation](./docs/API.md).

## Example
Check out ***[RingFetch](https://github.com/ysdragon/SysInfo/tree/main/examples)***, a complete system information display tool built with SysInfo.

|*RingFetch on a Linux VM*                                                                                   | *RingFetch on a Windows VM*                                                                           |
|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------|
|  ![](examples/img//ringfetch_linux.png)                                      |  ![](examples/img/ringfetch_win.png)                               |
                                                      

## Supported Operating Systems
### Fully Tested
- **<img width="20" height="20" src="https://www.kernel.org/theme/images/logos/favicon.png" /> Linux**
    - <img width="16" height="16" src="https://www.debian.org/favicon.ico" /> Debian
    - <img width="16" height="16" src="https://netplan.readthedocs.io/en/latest/_static/favicon.png" /> Ubuntu
    - <img width="16" height="16" src="https://voidlinux.org/assets/img/favicon.png" /> Void Linux
    - <img width="16" height="16" src="https://www.alpinelinux.org/alpine-logo.ico" /> Alpine Linux
    - <img width="16" height="16" src="https://www.centos.org/assets/img/favicon.png" /> CentOS
    - <img width="16" height="16" src="https://rockylinux.org/favicon.png" /> Rocky Linux
    - <img width="16" height="16" src="https://fedoraproject.org/favicon.ico" /> Fedora
    - <img width="16" height="16" src="https://almalinux.org/fav/favicon.ico" /> AlmaLinux
    - <img width="16" height="16" src="http://www.slackware.com/favicon.ico" /> Slackware Linux
    - <img width="16" height="16" src="https://github.com/bin456789/reinstall/assets/7548515/f74b3d5b-085f-4df3-bcc9-8a9bd80bb16d" /> Kali Linux
    - <img width="16" height="16" src="https://static.opensuse.org/favicon.ico" /> openSUSE
    - <img width="16" height="16" src="https://www.gentoo.org/assets/img/logo/gentoo-g.png" /> Gentoo Linux
    - <img width="16" height="16" src="https://archlinux.org/static/favicon.png" /> Arch Linux
    - <img width="16" height="16" src="https://www.devuan.org/ui/img/favicon.ico" /> Devuan Linux
    - <img width="16" height="16" src="https://chimera-linux.org/assets/icons/favicon48.png" /> Chimera Linux
    - <img width="16" height="16" src="https://www.openeuler.org/favicon.ico" /> openEuler
    - <img width="16" height="16" src="https://www.oracle.com/asset/web/favicons/favicon-32.png" /> Oracle
    - <img width="16" height="16" src="https://www.redhat.com/favicon.ico" /> Red Hat
- **<img width="20" height="20" src="https://www.freebsd.org/favicon.ico" /> FreeBSD**
    - FreeBSD 14
    - FreeBSD 15
- **<img width="20" height="20" src="https://blogs.windows.com/wp-content/uploads/prod/2022/09/cropped-Windows11IconTransparent512-32x32.png" /> Windows**
  - Windows 10
  - Windows 11
  - Windows Server 2019
  - Windows Server 2022
  - Windows Server 2025

## Contributing
Public contributions are welcome!  
You can create a [new issue](https://github.com/ysdragon/SysInfo/issues/new) for bugs, or feel free to open a [pull request](https://github.com/ysdragon/SysInfo/pulls) for any and all your changes or work-in-progress features.

## License
This project is open-source and available under the MIT License. See the [LICENSE](https://github.com/ysdragon/SysInfo/blob/main/LICENSE) file for more details.
