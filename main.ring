// The Main File

load "lib.ring"

func main() {
	print(`
    ** SysInfo package for the Ring Programming Language **
    ** Author: ysdragon (https://github.com/ysdragon)	 **

    Example:
        // Load SysInfo Package
        load "SysInfo.ring"
        // Create a new instance of the SysInfo class
        sys = new SysInfo
        // Get OS name
        osName = sys.os()
        // Get CPU name
        cpuName = sys.cpu()[:name]
        // Get CPU cores
        cpuCores = sys.cpu()[:cores]
        // Get CPU threads
        cpuThreads = sys.cpu()[:threads]

        ? osName
        ? cpuName + " " + cpuCores + " " + cpuThreads

    // A complete good example can be found in the package's examples folder.
	\n`)
}