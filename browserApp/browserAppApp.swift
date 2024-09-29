//
//  browserAppApp.swift
//  browserApp
//
//  Created by Adam Makowski on 01/08/2024.
//

import SwiftUI

@main
struct browserAppApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView().environmentObject(BrowserViewModel())
        }
    }
}
