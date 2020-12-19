//
//  AppDelegate.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 16/12/2020.
//

import Cocoa
import SwiftUI
import Preferences
import Defaults
import Carbon

extension Preferences.PaneIdentifier {
    static let vpnconf = Self("vpnconf")
}

@available(OSX 11.0, *)
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusItem: NSStatusItem?
    var t: RepeatingTimer!
    let openfortivpn = VPNProcessUtil.instance
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var connectMenuItem: NSMenuItem?
    
    lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: .vpnconf,
                 title: "General",
                 toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "VPN Configuration")!
            ) {
                PreferencesView()
            }
        ]
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to bootstrap your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if openfortivpn.isBackgroundProcessRunning() {
            //Kill it!
            openfortivpn.killBackgroundProcess()
        }
    }
    
    @IBAction private func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
        preferencesWindowController.show()
    }
    
    @IBAction private func connectToVPN(_ sender: NSMenuItem) {
        if sender.state == NSControl.StateValue.on {
            //Ok let's kill it
            if openfortivpn.killBackgroundProcess() {
                //Change the state of the menuitem
                sender.state = NSControl.StateValue.off
                sender.title = "Connect"
                return
            }
        }
        
        if openfortivpn.startBackgroundProcess() {
            //Start the timer thread to control our vpn is still up and running
            
            //Change the state of the menuitem
            sender.state = NSControl.StateValue.on
            sender.title = "Disconnect"
            
            t = RepeatingTimer(timeInterval: 60)
            t.eventHandler = {
                let running = self.openfortivpn.isBackgroundProcessRunning()
                if !running {
                    //Change the state of the menuitem
                    sender.state = NSControl.StateValue.off
                    sender.title = "Connect"
                }
            }
            t.resume()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
         
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(named: "Icon")
        
        if let menu = menu {
            statusItem?.menu = menu
        }
    }
}

