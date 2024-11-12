/*
    SysInfo Package Test Suite
*/

load "SysInfo.ring"

func main() {
    tests = new SysInfoTest()
    tests.runAllTests()
}

class SysInfoTest {
    sysInfo

    func init() {
        sysInfo = new SysInfo
    }

    func assert(condition, message) {
        if (!condition) {
            raise("Assertion failed: " + message)
        }
    }

    func runAllTests() {
        ? "Starting SysInfo Test Suite..."
        
        testHostname()
        testUsername()
        testOS()
        testVersion()
        testCPU()
        testGPU()
        testShell()
        testTerm()
        testRAM()
        testStorageDisks()
        testStorageParts()
        testSysUptime()
        testArch()
        testPCount()
        testIsVM()
        
        ? "All tests completed successfully!"
    }

    func testHostname() {
        ? "Testing hostname()..."
        hostname = sysInfo.hostname()
        assert(!isNull(hostname), "Hostname should not be null")
        assert(len(hostname) > 0, "Hostname should not be empty")
    }

    func testUsername() {
        ? "Testing username()..."
        username = sysInfo.username()
        assert(!isNull(username), "Username should not be null")
        assert(len(username) > 0, "Username should not be empty")
    }

    func testOS() {
        ? "Testing os()..."
        osInfo = sysInfo.os()
        assert(isList(osInfo), "OS info should be a list")
        assert(!isNull(osInfo[:name]), "OS name should not be null")
        assert(!isNull(osInfo[:id]), "OS ID should not be null")
    }

    func testVersion() {
        ? "Testing version()..."
        version = sysInfo.version()
        assert(!isNull(version), "Version should not be null")
        assert(len(version) > 0, "Version should not be empty")
    }

    func testCPU() {
        ? "Testing cpu()..."
        cpuInfo = sysInfo.cpu()
        assert(isList(cpuInfo), "CPU info should be a list")
        assert(!isNull(cpuInfo[:name]), "CPU name should not be null")
        assert(number(cpuInfo[:cores]) > 0, "CPU cores should be greater than 0")
        assert(number(cpuInfo[:threads]) > 0, "CPU threads should be greater than 0")
    }

    func testGPU() {
        ? "Testing gpu()..."
        gpuInfo = sysInfo.gpu()
        assert(!isNull(gpuInfo), "GPU info should not be null")
    }

    func testShell() {
        ? "Testing shell()..."
        shell = sysInfo.shell()
        assert(isList(shell), "Shell info should be a list")
        assert(!isNull(shell[:name]), "Shell name should not be null")
        assert(!isNull(shell[:version]), "Shell version should not be null")
    }

    func testTerm() {
        ? "Testing term()..."
        term = sysInfo.term()
        if isUnix() {
            assert(!isNull(term), "Terminal info should not be null")
            assert(len(term) > 0, "Terminal info should not be empty")
        }
    }

    func testRAM() {
        ? "Testing ram()..."
        ramInfo = sysInfo.ram()
        assert(isList(ramInfo), "RAM info should be a list")
        assert(number(ramInfo[:size]) > 0, "RAM size should be greater than 0")
        assert(number(ramInfo[:used]) >= 0, "RAM used should be non-negative")
        assert(number(ramInfo[:free]) >= 0, "RAM free should be non-negative")
    }

    func testStorageDisks() {
        ? "Testing storageDisks()..."
        disks = sysInfo.storageDisks()
        assert(isList(disks), "Storage disks should be a list")
        assert(len(disks) > 0, "At least one storage disk should be present")
        
        for disk in disks {
            assert(!isNull(disk[:name]), "Disk name should not be null")
            assert(!isNull(disk[:size]), "Disk size should not be null")
        }
    }

    func testStorageParts() {
        ? "Testing storageParts()..."
        parts = sysInfo.storageParts()
        assert(isList(parts), "Storage partitions should be a list")
        assert(len(parts) > 0, "At least one partition should be present")
        
        for part in parts {
            assert(!isNull(part[:name]), "Partition name should not be null")
            assert(!isNull(part[:size]), "Partition size should not be null")
            assert(!isNull(part[:used]), "Partition used space should not be null")
            assert(!isNull(part[:free]), "Partition free space should not be null")
        }
    }

    func testSysUptime() {
        ? "Testing sysUptime()..."
        params = [:days = 1, :hours = 1, :minutes = 1, :seconds = 1]
        uptime = sysInfo.sysUptime(params)
        assert(!isNull(uptime), "Uptime should not be null")
        assert(len(uptime) > 0, "Uptime should not be empty")
    }

    func testArch() {
        ? "Testing arch()..."
        arch = sysInfo.arch()
        assert(!isNull(arch), "Architecture should not be null")
        assert(len(arch) > 0, "Architecture should not be empty")
    }

    func testPCount() {
        ? "Testing pCount()..."
        pcount = sysInfo.pCount()
        assert(!isNull(pcount), "Package count should not be null")
    }

    func testIsVM() {
        ? "Testing isVM()..."
        isVM = sysInfo.isVM()
        assert(isBoolean(isVM) or isNull(isVM), "isVM should be boolean or null")
    }

    // Helper function to check if value is boolean
    func isBoolean(value) {
        return type(value) = "NUMBER" and (value = 0 or value = 1)
    }
}