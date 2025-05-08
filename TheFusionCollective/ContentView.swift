//
//  ContentView.swift
//  TheFusionCollective
//
//  Created by nandana on 4/22/25.
//

import SwiftUI

extension Color {
    static let chestnut = Color(red: 149/255, green: 69/255, blue:  53/255) 
    static let beige = Color(red: 245/255, green: 222/255, blue: 179/255)
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.beige
                    .ignoresSafeArea()
//                Image("yarn.png")
//                    .resizable()
//                    .ignoresSafeArea()
                VStack(spacing: 10) {
                    Text("The")
                        .bold()
                        .font(.custom("Times New Roman", size: 60))
                        .foregroundColor(.chestnut)
                    Text("Fusion")
                        .bold()
                        .italic()
                        .font(.custom("Times New Roman", size: 66))
                        .foregroundColor(.chestnut)
                    Text("Collective")
                        .bold()
                        .font(.custom("Times New Roman", size: 60))
                        .foregroundColor(.chestnut)
                    Text("Art, Fashion, Design,                 and everything in between.")
                        .font(.custom("Times New Roman", size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .bold()
                        .italic()
                    NavigationLink(">") {
                        LoginView()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 20))
                    .tint(.chestnut)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
