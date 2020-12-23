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
}

struct AdvancedPreferencesView: View {
    @Default(.shouldSetRoutes) private var shouldSetRoutes
    @Default(.shouldSetDNS) private var shouldSetDNS
    @Default(.shouldUseSyslog) private var shouldUseSyslog
    var body: some View {
        Text("Do not change anything in this section unless you really know what you are doing!")
            .frame(width: 430.0, height: 40.0)
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Set routes") {
                HStack {
                    Toggle("", isOn: $shouldSetRoutes).toggleStyle(SwitchToggleStyle())
                    Text("Set if it should try to configure IP routes through the VPN when tunnel is up")
                        .frame(width: 200.0)
                        .font(.system(size: 9, weight: .light))
                }
            }
            Preferences.Section(title: "Set DNS") {
                HStack {
                    Toggle("", isOn: $shouldSetDNS).toggleStyle(SwitchToggleStyle())
                    Text("Set if it should add DNS name servers in resolv.conf when  tunnel is  up")
                        .frame(width: 200.0)
                        .font(.system(size: 9, weight: .light))
                }
            }
            Preferences.Section(title: "Use syslog") {
                HStack {
                    Toggle("", isOn: $shouldUseSyslog).toggleStyle(SwitchToggleStyle())
                    Text("Set if log things in syslog. This is recommended otherwise logs will be lost.")
                        .frame(width: 200.0)
                        .font(.system(size: 9, weight: .light))
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
