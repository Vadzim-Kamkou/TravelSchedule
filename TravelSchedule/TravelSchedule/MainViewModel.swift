import Foundation
import SwiftUI
import OpenAPIURLSession
import Combine

@MainActor
class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var departureSettlement: Settlement?
    @Published var departureStation: Station?
    @Published var arrivalSettlement: Settlement?
    @Published var arrivalStation: Station?
    @Published var allStationsData: AllStations?
    @Published var isLoadingStations = false
    @Published var errorMessage: String?
    @Published var showNetworkError = false
    @Published var viewedStories: Set<Int> = []
    
    // MARK: - Navigation State
    @Published var showDepartureSelection = false
    @Published var showArrivalSelection = false
    @Published var showScheduleList = false
    @Published var showStories = false
    @Published var selectedStoryIndex = 0
    
    // MARK: - Services
    private let allStationsService: AllStationsService
    
    // MARK: - Initialization
    init() {
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
            fatalError("Failed to initialize MainViewModel: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func loadAllStationsIfNeeded() async {
        guard allStationsData == nil, !isLoadingStations else { return }
        
        isLoadingStations = true
        errorMessage = nil
        showNetworkError = false
        
        do {
            let stations = try await allStationsService.getAllStations()
            allStationsData = stations
            errorMessage = nil
            showNetworkError = false
        } catch {
            let errorType = determineErrorType(error)
            switch errorType {
            case .noInternet:
                errorMessage = String(localized: "error_no_internet")
            case .timeout:
                errorMessage = String(localized: "error_timeout")
            case .serverError, .other:
                errorMessage = "Ошибка загрузки станций: \(error.localizedDescription)"
            }
            showNetworkError = true
            print("Error loading stations: \(error)")
        }
        
        isLoadingStations = false
    }
    
    func setDepartureSelection(settlement: Settlement, station: Station) {
        departureSettlement = settlement
        departureStation = station
    }
    
    func setArrivalSelection(settlement: Settlement, station: Station) {
        arrivalSettlement = settlement
        arrivalStation = station
    }
    
    func canShowSchedule() -> Bool {
        departureSettlement != nil &&
        departureStation != nil &&
        arrivalSettlement != nil &&
        arrivalStation != nil
    }
}
