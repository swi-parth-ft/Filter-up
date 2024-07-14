//
//  ContentView.swift
//  Filter up
//
//  Created by Parth Antala on 2024-07-14.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white
    
    var body: some View {
        Button("Hello, World!") {
            withAnimation {
                showingConfirmation.toggle()
            }
        }
        .frame(width: 300, height: 300)
        .background(backgroundColor)
        .confirmationDialog("Change Background", isPresented: $showingConfirmation) {

            Button("Red") { backgroundColor = .red}
                Button("Green") { backgroundColor = .green}
                Button("Blue") { backgroundColor = .blue}
                Button("Orange") { backgroundColor = .orange}
                Button("Cancel", role: .cancel) { }
            
        }
    }
}

#Preview {
    ContentView()
}
