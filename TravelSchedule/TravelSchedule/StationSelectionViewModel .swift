import Foundation
import SwiftUI
import Combine

@MainActor
class StationSelectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    
    // MARK: - Dependencies
    let selectedSettlement: Settlement
    
    // MARK: - Computed Properties
    var allStations: [Station] {
        selectedSettlement.stations ?? []
    }
    
    var displayedStations: [Station] {
        if searchText.isEmpty {
            return allStations
        } else {
            return allStations.filter { station in
                guard let title = station.title else { return false }
                return title.lowercased().hasPrefix(searchText.lowercased())
            }
        }
    }
    
    // MARK: - Initialization
    init(selectedSettlement: Settlement) {
        self.selectedSettlement = selectedSettlement
    }
}
