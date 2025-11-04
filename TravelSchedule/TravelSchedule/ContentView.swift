//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Vadzim on 4.11.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // Вызываем нашу тестовую функцию при появлении View
            
            testFetchStations()
        }
    }
}

#Preview {
    ContentView()
}
