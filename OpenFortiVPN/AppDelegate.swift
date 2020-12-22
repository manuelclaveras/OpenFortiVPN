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

    var window: NSWindow!
    var statusItem: NSStatusItem?
    var t: RepeatingTimer!
    var killedByUser: Bool = false
    var notificationSent: Bool = false
    let openfortivpn = VPNProcessUtil.instance
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
        if openfortivpn.isBackgroundProcessRunning() {
            //Kill it!
            openfortivpn.killBackgroundProcess()
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

    @IBAction private func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
        preferencesWindowController.show()
    }
    
    @IBAction private func connectToVPN(_ sender: NSMenuItem) {
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
                self.killedByUser = true
                return
            }
        }
        
        if openfortivpn.startBackgroundProcess() {
            //Start the timer thread to control our vpn is still up and running
            
            //Change the state of the menuitem
            sender.state = NSControl.StateValue.on
            sender.title = "Disconnect"
            
            //Set the background process in charge of checking if
            //the process is still running
            t = RepeatingTimer(timeInterval: 20)
            t.eventHandler = {
                let running = self.openfortivpn.isBackgroundProcessRunning()
                if !running {
                    //Change the state of the menuitem
                    sender.state = NSControl.StateValue.off
                    sender.title = "Connect"
                    
                    //Send a notification
                    if !self.killedByUser {
                        self.sendNotification(
                            title: "Connections wit VPN lost",
                            subtitle: "",
                            body: "Click on Connect to restart a new connection"
                        )
                    }
                }
            }
            t.resume()
            
            //Send a notification to the user!
            sendNotification(title: "Woohoo!", subtitle: "", body: "You're connected to the VPN")
        }
    }
    
    private func sendNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "openfortivpn.id.1", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

