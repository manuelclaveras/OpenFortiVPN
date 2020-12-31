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
import UserNotifications

extension Preferences.PaneIdentifier {
    static let vpnconf = Self("vpnconf")
    static let general = Self("general")
    static let advanced = Self("advanced")
}

@available(OSX 11.0, *)
@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem?
    var t: RepeatingTimer!
    var killedByUser: Bool = false
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var connectMenuItem: NSMenuItem?
    
    lazy var preferencesWindowController = PreferencesWindowController(
        panes: [
            Preferences.Pane(
                identifier: .general,
                title: "General",
                toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General configuration")!
            ) {
                GeneralPreferencesView()
            },
            Preferences.Pane(
                identifier: .vpnconf,
                title: "Configuration",
                toolbarIcon: NSImage(systemSymbolName: "network", accessibilityDescription: "VPN Configuration")!
            ) {
                PreferencesView()
            },
            Preferences.Pane(
                identifier: .advanced,
                title: "Advanced",
                toolbarIcon: NSImage(systemSymbolName: "plus", accessibilityDescription: "Advanced configuration")!
            ) {
                AdvancedPreferencesView()
            }
        ]
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])  {
            success, error in
                if success {
                    NSLog("Great! Notifications accepted")
                } else {
                    NSLog(":(")
                }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        let openfortivpn = VPNProcessUtil()
        if openfortivpn.isBackgroundProcessRunning() {
            //Kill it!
            let _ = openfortivpn.killBackgroundProcess()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
         
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(named: "DisconnectIcon")
        
        if let menu = menu {
            statusItem?.menu = menu
        }
    }

    @IBAction private func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
        preferencesWindowController.show()
    }
    
    @IBAction private func connectToVPN(_ sender: NSMenuItem) {
        let openfortivpn = VPNProcessUtil()
        //Detect openfortivpn installation
        if !openfortivpn.isOpenfortivpnInstalled() {
            let alert = NSAlert()
            alert.messageText = "Cannot find openfortivpn CLI"
            alert.informativeText = """
                By default, we search the usual folders. Usually this means the client has not been installed,
                you can install it using Homebrew or Macports. If it's already installed, check the preferences
                and provide the installation path.
            """
            alert.alertStyle = .critical
            alert.addButton(withTitle: "Got it!")
            alert.runModal()
            return
        }
        
        if sender.state == NSControl.StateValue.on {
            //Ok let's kill it
            if openfortivpn.killBackgroundProcess() {
                //Change the state of the menuitem
                sender.state = NSControl.StateValue.off
                sender.title = "Connect"
                statusItem?.button?.image = NSImage(named: "DisconnectIcon")
                statusItem?.button?.needsDisplay = true
                self.killedByUser = true
                t = nil //deinit the timer
                return
            }
        }
        
        if openfortivpn.startBackgroundProcess() {
            //Start the timer thread to control our vpn is still up and running
            
            //Change the state of the menuitem
            sender.state = NSControl.StateValue.on
            sender.title = "Disconnect"
            statusItem?.button?.image = NSImage(named: "Icon")
            statusItem?.button?.needsDisplay = true
            
            //Set the background process in charge of checking if
            //the process is still running
            if t == nil {
                t = RepeatingTimer(timeInterval: 20)
                t.eventHandler = {
                    let openfortivpn = VPNProcessUtil()
                    let running = openfortivpn.isBackgroundProcessRunning()
                    if !running {
                        let button = sender
                        let statusBar = self.statusItem
                        //Change the state of the &menuitem
                        button.state = NSControl.StateValue.off
                        button.title = "Connect"
                        statusBar?.button?.image = NSImage(named: "DisconnectIcon")
                        statusBar?.button?.needsDisplay = true
                        
                        //Send a notification
                        if !self.killedByUser {
                            NotificationUtil.sendNotification(
                                title: "Connections wit VPN lost",
                                subtitle: "",
                                body: "Click on Connect to restart a new connection"
                            )
                        }
                    }
                }
            }
            t.resume()
            
            //Send a notification to the user!
            NotificationUtil.sendNotification(title: "Woohoo!", subtitle: "", body: "You're connected to the VPN")
        }
    }
}

