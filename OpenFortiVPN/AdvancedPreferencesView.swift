//
//  AdvancedPreferencesView.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 22/12/2020.
//

import SwiftUI
import Preferences

struct AdvancedPreferencesView: View {
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Blu") {
                Text("Hello World")
            }
        }
    }
}

struct AdvancedPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedPreferencesView()
    }
}
