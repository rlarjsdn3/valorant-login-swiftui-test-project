//
//  ValorantLoginTestApp.swift
//  ValorantLoginTest
//
//  Created by 김건우 on 2023/09/06.
//

import SwiftUI

@main
struct ValorantLoginTestApp: App {
    
    @StateObject var loginManager = LoginManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginManager)
        }
    }
}
