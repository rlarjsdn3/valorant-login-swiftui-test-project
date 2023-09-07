//
//  ContentView.swift
//  ValorantLoginTest
//
//  Created by 김건우 on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    
    let loginManager = LoginManager()
    
    @State private var inputUsername: String = "rlaansdj3"
    @State private var inputPassword: String = "@ch907678"
    
    @State private var weaponSkinsUuid: [String] = []
    
    var body: some View {
        VStack {
            ForEach(weaponSkinsUuid, id: \.self) { uuid in
                if let url = URL(string: "https://media.valorant-api.com/weaponskinlevels/\(uuid)/displayicon.png") {
                    AsyncImage(url: url)
                        .frame(width: 100, height: 100, alignment: .center)
                }
            }
            
            Group {
                TextField("아이디", text: $inputUsername, prompt: Text("아이디"))
                TextField("패스워드", text: $inputPassword, prompt: Text("패스워드"))
            }
            .textInputAutocapitalization(.never)
            .textFieldStyle(.roundedBorder)
            
            Button("로그인") {
                Task {
                    if let skinsUuid =  await loginManager.run(
                        username: inputUsername,
                        password: inputPassword
                    ) {
                        weaponSkinsUuid = skinsUuid
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 8)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
