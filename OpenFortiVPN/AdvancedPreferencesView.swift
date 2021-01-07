//
//  AdvancedPreferencesView.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 22/12/2020.
//

import SwiftUI
import Preferences
import Defaults

extension Defaults.Keys {
    static let shouldSetRoutes = Key<Bool>("shouldSetRoutes", default: true)
    static let shouldSetDNS = Key<Bool>("shouldSetDNS", default: false)
    static let shouldUseResolv = Key<Bool>("shouldUseResolv", default: false)
    static let shouldUseSyslog = Key<Bool>("shouldUseSyslog", default: true)
    static let shouldAutoReconnect = Key<Bool>("shouldAutoReconnect", default: true)
}

struct AdvancedPreferencesView: View {
    @Default(.shouldSetRoutes) private var shouldSetRoutes
    @Default(.shouldSetDNS) private var shouldSetDNS
    @Default(.shouldUseSyslog) private var shouldUseSyslog
    @Default(.shouldAutoReconnect) private var shouldAutoReconnect
    var body: some View {
        Text("Do not change anything in this section unless you really know what you are doing!")
            .frame(width: 430.0, height: 40.0)
        Preferences.Container(contentWidth: 430.0) {
            Preferences.Section(title: "Configure IP routes through the VPN when tunnel is up") {
                HStack {
                    Toggle("", isOn: $shouldSetRoutes).toggleStyle(SwitchToggleStyle())
                }
            }
            Preferences.Section(title: "Add DNS name servers in resolv.conf when  tunnel is  up") {
                HStack {
                    Toggle("", isOn: $shouldSetDNS).toggleStyle(SwitchToggleStyle())
                }
            }
            Preferences.Section(title: "Log things in syslog") {
                HStack {
                    Toggle("", isOn: $shouldUseSyslog).toggleStyle(SwitchToggleStyle())
                }
            }
            Preferences.Section(title: "Automatically reconnect if connection is dropped") {
                HStack {
                    Toggle("", isOn: $shouldAutoReconnect).toggleStyle(SwitchToggleStyle())
                }
            }
        }
    }
}

struct AdvancedPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedPreferencesView()
    }
}
