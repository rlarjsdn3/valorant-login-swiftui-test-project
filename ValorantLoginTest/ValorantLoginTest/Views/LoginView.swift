//
//  LoginView.swift
//  ValorantLoginTest
//
//  Created by 김건우 on 2023/09/08.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var loginManager: LoginManager
    
    @State private var inputUsername: String = "rlaansdj3"
    @State private var inputPassword: String = "@ch907678"
    
    var body: some View {
        VStack {
            Group {
                TextField("아이디", text: $inputUsername, prompt: Text("아이디"))
                TextField("패스워드", text: $inputPassword, prompt: Text("패스워드"))
            }
            .textInputAutocapitalization(.never)
            .textFieldStyle(.roundedBorder)
            
            Button("로그인") {
                Task {
                    if let _ =  await loginManager.run(
                        username: inputUsername,
                        password: inputPassword
                    ) {
                        
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 8)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LoginManager())
    }
}
