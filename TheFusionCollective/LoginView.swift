//
//  LoginView.swift
//  TheFusionCollective
//
//  Created by nandana on 4/22/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loggedIn = false
    var body: some View {
        ZStack {
            Color.beige
                .ignoresSafeArea()
            VStack(spacing: 20) {
                HStack {
                    Text("Username:")
                        .bold()
                    TextField("Username", text: $username)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Password:")
                        .bold()
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                Button("Login") {
                    loggedIn = true
                }
                .disabled(username.isEmpty || password.isEmpty)
                .buttonStyle(.borderedProminent)
                .tint(.chestnut)
                .buttonBorderShape(.roundedRectangle(radius: 20))
            }
            .padding(.horizontal)
            .navigationTitle("Login")
            .navigationDestination(isPresented: $loggedIn) {
                CollectionsView(username: username)
            }
        }
    }
}

#Preview {
    LoginView()
}
