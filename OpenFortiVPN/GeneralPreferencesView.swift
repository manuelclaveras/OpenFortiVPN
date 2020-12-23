//
//  GeneralPreferencesView.swift
//  OpenFortiVPN
//
//  Created by Manuel Claveras on 22/12/2020.
//

import SwiftUI
import Preferences
import Defaults

extension Defaults.Keys {
    static let defaultPath = Key<String>("defaultPath", default: "/usr/local/bin")
}

struct GeneralPreferencesView: View {
    @Default(.defaultPath) private var defaultPath
    var body: some View {
        Preferences.Container(contentWidth: 450.0) {
            Preferences.Section(title: "Path") {
                HStack {
                    TextField(
                        "Server Address",
                        text: $defaultPath
                    )
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300.0)
                    Button("Choose") {
                        let dialog = NSOpenPanel();

                        dialog.title                   = "Choose single directory";
                        dialog.showsResizeIndicator    = true;
                        dialog.showsHiddenFiles        = true;
                        dialog.canChooseFiles = false;
                        dialog.canChooseDirectories = true;

                        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                            let result = dialog.url
                            if (result != nil) {
                                defaultPath = result!.path
                            }
                        } else {
                            return
                        }
                    }
                }
            }
        }
    }
}

struct GeneralPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPreferencesView()
    }
}
