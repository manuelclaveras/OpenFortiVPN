//
//  ContentView.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 16/12/2020.
//

import SwiftUI
import Preferences
import Defaults

extension Defaults.Keys {
    static let username = Key<String>("username", default: "")
    static let password = Key<String>("password", default: "")
    static let serverAddress = Key<String>("serverAddress", default: "")
    static let port = Key<String>("port", default: "443")
    static let cert = Key<String>("cert", default: "")
}

struct PreferencesView: View {
    @Default(.username) private var username
    @Default(.password) private var password
    @Default(.serverAddress) private var serverAddress
    @Default(.port) private var port
    @Default(.cert) private var cert
    
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Address") {
                TextField(
                    "Server Address",
                    text: $serverAddress
                )
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350.0)
                Text("This is the server address, it can be an IP address").preferenceDescription()
            }
            Preferences.Section(title: "Port", bottomDivider: true) {
                TextField(
                    "Port",
                    text: $port
                )
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350.0)
                Text("This is the server port").preferenceDescription()
            }
            Preferences.Section(title: "Username") {
                TextField(
                    "Username",
                    text: $username
                )
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350.0)
                Text("This is your provided user name")
                                    .preferenceDescription()
            }
            Preferences.Section(title: "Password") {
                SecureField(
                    "Password",
                    text: $password
                )
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350.0)
                Text("This is your provided password")
                                    .preferenceDescription()
            }
            Preferences.Section(title: "Certificate") {
                TextField(
                    "Certificate",
                    text: $cert
                )
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 350.0)
                Text("This is your provided certificate")
                                    .preferenceDescription()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
