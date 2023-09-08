//
//  ShopView.swift
//  ValorantLoginTest
//
//  Created by 김건우 on 2023/09/08.
//

import SwiftUI

struct ShopView: View {
    
    @EnvironmentObject var loginManager: LoginManager
    
    var body: some View {
        ScrollView {
            ForEach(loginManager.skinsUuid, id: \.self) { uuid in
                if let url = URL(string: "https://media.valorant-api.com/weaponskinlevels/\(uuid)/displayicon.png") {
                    AsyncImage(url: url)
                        .frame(width: 400, height: 100, alignment: .center)
                }
            }
            
            Button("새로고침") {
                //...
            }
            .buttonStyle(.borderedProminent)
            
            Button("로그아웃") {
                loginManager.isAuthenticated = false
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
            .environmentObject(LoginManager())
    }
}
