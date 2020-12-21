//
//  VPNProcessUtil.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 18/12/2020.
//

import Foundation
import Cocoa
import Defaults

class VPNProcessUtil {
    static var instance: VPNProcessUtil = {
        return VPNProcessUtil()
    }()
    
    ///This method checks if the openfortivpn process runs by using
    ///sysctl to list all the processes.
    ///
    ///- parameters: No parameters
    ///- returns: A boolean value to true if the process has been found
    func isBackgroundProcessRunning() -> Bool {
        return getPid() != nil
    }
    
    ///This method starts the openfortivpn process using a NSAppleScript to gain
    ///priviledge elevation, it will as for user password 
    ///
    ///- parameters: No parameters
    ///- returns: A boolean value to true if the process has been found
    func startBackgroundProcess() -> Bool {
        let user = Defaults[.username]
        let pwd = Defaults[.password]
        let host = Defaults[.serverAddress]
        let port = Defaults[.port]
        let cert = Defaults[.cert]
        
        let ascript: String = "do shell script \"/usr/local/bin/openfortivpn \(host):\(port) -u \(user) -p \(pwd) --trusted-cert \(cert) > /dev/null 2>&1 &\" with administrator privileges"
        
        if let script = NSAppleScript(source: ascript) {
            NSLog("Starting openfortivpn")
            var err = NSDictionary()
            let errPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>.init(&err)
            script.executeAndReturnError(errPointer)
            return true
        }
        
        return false
    }
    
    ///This function kills the openfortivpn process. The underlying code just uses the getPid method to find
    ///the pid and NSAppleScript to do a kill command because we need priviledge elevation (again)
    ///
    ///- parameters: No parameters
    ///- returns: a bool value, true if the kill was ok and false otherwise
    func killBackgroundProcess() -> Bool {
        //get oid of openfortivpn
        let pid = getPid()
        
        guard pid != nil else {
            return false
        }
        
        let id = String(pid!)
        
        let ascript: String = "do shell script \"kill -9 \(id)\" with administrator privileges"
        
        if let script = NSAppleScript(source: ascript) {
            NSLog("Killing openfortivpn")
            var err = NSDictionary()
            let errPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>.init(&err)
            script.executeAndReturnError(errPointer)
            return true
        }
        
        return false
    }
    
    ///This function verifies if the openfortivpn client is installed in the usual directories
    ///
    ///- parameters: No parameters
    ///- returns: a boolean to indicate if it was found or not
    func isOpenfortivpnInstalled() -> Bool {
        let manager = FileManager.default
        let info = ProcessInfo.processInfo
        NSLog(info.environment["PATH"] ?? "Arf")
        return manager.fileExists(atPath: "/usr/local/bin/sbin/openfortivpn")
    }
    
    private func getPid() -> Int? {
        //Get the total number of processes running
        var name : [Int32] = [ CTL_KERN, KERN_PROC, KERN_PROC_ALL ]
        var size = size_t()
        sysctl(&name, UInt32(name.count), nil, &size, nil, 0)
        let count = size / MemoryLayout<kinfo_proc>.size
        var procList = Array(repeating: kinfo_proc(), count: count)
        let result = sysctl(&name, UInt32(name.count), &procList, &size, nil, 0)
        
        //Hey that's not cool
        guard result == 0 else {
            return nil
        }
        
        //Find the process openfortivpn in the list
        let processes = Array(procList.prefix(size / MemoryLayout<kinfo_proc>.size))
        for process in processes {
            var proc = process
            let command = withUnsafePointer(to: &proc.kp_proc.p_comm) {
                String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
            }
            
            if (command.contains("openfortivpn")) {
                return Int(proc.kp_proc.p_pid)
            }
        }
        return nil
    }
}
