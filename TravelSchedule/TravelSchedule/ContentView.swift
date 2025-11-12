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
        .onAppear
        {
            Task {
                print("All Service Tests...\n")
                
                print("1. Test Copyright Service")
                testFetchCopyright()
                try? await Task.sleep(for: .seconds(2))
                
                print("\n2. Test All Stations Service")
                testFetchAllStations()
                try? await Task.sleep(for: .seconds(3))
                
                print("\n3. Test Nearest City Service")
                testFetchNearestCity()
                try? await Task.sleep(for: .seconds(2))
                
                print("\n4. Test Nearest Stations Service")
                testFetchStations()
                try? await Task.sleep(for: .seconds(2))
                
                print("\n5. Test Station Schedule Service")
                testFetchStationSchedule()
                try? await Task.sleep(for: .seconds(2))
                
                print("\n6. Test Schedule Between Stations Service")
                testFetchScheduleBetweenStations()
                try? await Task.sleep(for: .seconds(2))
                
                print("\n7. Test Route Stations Service")
                testFetchRouteStations()
                try? await Task.sleep(for: .seconds(2))
                
                print("\n8. Test Carrier Info Service")
                testFetchCarrierInfo()
                try? await Task.sleep(for: .seconds(2))
                
                print("\nAll test finished!")
            }
        }
    }
}

#Preview {
    ContentView()
}
