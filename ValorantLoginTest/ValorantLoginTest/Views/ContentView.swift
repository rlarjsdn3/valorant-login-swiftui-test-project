//
//  ContentView.swift
//  ValorantLoginTest
//
//  Created by 김건우 on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var loginManger: LoginManager
    
    var body: some View {
        if loginManger.isAuthenticated {
            ShopView()
                .onAppear {
                    print(loginManger.isAuthenticated)
                }
        } else {
            LoginView()
                .onAppear {
                    print(loginManger.isAuthenticated)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginManager())
    }
}
