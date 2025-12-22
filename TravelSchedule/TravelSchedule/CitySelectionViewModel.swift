import Foundation
import SwiftUI
import OpenAPIURLSession
import Combine

@MainActor
class CitySelectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var allSettlements: [Settlement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var errorType: NetworkErrorType?
    
    // MARK: - Dependencies
    @Binding var allStationsData: AllStations?
    private let allStationsService: AllStationsService
    
    // MARK: - Constants
    private let predefinedCityNames: [String] = [
        "Минск",
        "Могилёв",
        "Москва",
        "Санкт-Петербург",
        "Екатеринбург",
        "Новосибирск",
        "Казань"
    ]
    
    // MARK: - Computed Properties
    var predefinedSettlements: [Settlement] {
        predefinedCityNames.compactMap { cityName in
            allSettlements.first { settlement in
                settlement.title == cityName
            }
        }
    }
    
    var displayedSettlements: [Settlement] {
        if searchText.isEmpty {
            return predefinedSettlements
        } else {
            return allSettlements
                .filter { settlement in
                    guard let title = settlement.title else { return false }
                    return title.lowercased().hasPrefix(searchText.lowercased())
                }
                .sorted { settlement1, settlement2 in
                    (settlement1.title ?? "") < (settlement2.title ?? "")
                }
        }
    }
    
    // MARK: - Initialization
    init(allStationsData: Binding<AllStations?>) {
        self._allStationsData = allStationsData
        
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            self.allStationsService = AllStationsService(
                client: client,
                apikey: APIConfiguration.apiKey
            )
        } catch {
            fatalError("Failed to initialize CitySelectionViewModel: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func loadDataIfNeeded() async {
        if let existingData = allStationsData {
            prepareSettlements(from: existingData)
        } else {
            await loadAllStations()
        }
    }
    
    func loadAllStations() async {
        isLoading = true
        errorMessage = nil
        errorType = nil
        
        do {
            let stations = try await allStationsService.getAllStations()
            allStationsData = stations
            prepareSettlements(from: stations)
            isLoading = false
        } catch {
            isLoading = false
            errorType = determineErrorType(error)
            errorMessage = error.localizedDescription
            print("Error loading stations: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func prepareSettlements(from allStations: AllStations) {
        var result: [Settlement] = []
        
        allStations.countries?.forEach { country in
            country.regions?.forEach { region in
                if let settlements = region.settlements {
                    result.append(contentsOf: settlements)
                }
            }
        }
        
        allSettlements = result
    }
}
