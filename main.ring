// The Main File

load "lib.ring"

func main() {
	print(`
	** SysInfo package for the Ring Programming Language **
	** Author: ysdragon (https://github.com/ysdragon)	 **

	Example:
		// Load SysInfo Package
		load "SysInfo.ring"

		// Create a new SysInfo instance
		sys = new SysInfo

		// Get basic system information
		? "OS: " + sys.os()[:name]
		? "Hostname: " + sys.hostname()
		? "CPU: " + sys.cpu([])[:model]
		? "Total RAM: " + (sys.ram()[:size] / 1024 / 1024) + " GB"

		// A complete good example can be found in the package's examples folder.
	\n`)
}