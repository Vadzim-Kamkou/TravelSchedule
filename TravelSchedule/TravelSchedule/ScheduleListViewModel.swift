import Foundation
import SwiftUI
import Combine
import OpenAPIURLSession

@MainActor
class ScheduleListViewModel: ObservableObject {
    @Published var allSegments: [ScheduleSegmentDisplay] = []
    @Published var filteredSegments: [ScheduleSegmentDisplay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filterSettings = FilterSettings()
    
    
    private let client: Client
    private let apiKey: String
    
    var segments: [ScheduleSegmentDisplay] {
        filteredSegments
    }
    
    init() {
        do {
            self.client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            self.apiKey = APIConfiguration.apiKey
        } catch {
            fatalError("Failed to initialize client: \(error)")
        }
    }
    
    func loadSchedule(
        from fromStation: Station,
        to toStation: Station
    ) async {
        guard let fromCode = fromStation.codes?.yandex_code,
              let toCode = toStation.codes?.yandex_code else {
            errorMessage = "Ошибка получения кодов станций"
            return
        }
        
        isLoading = true
        errorMessage = nil
        allSegments = []
        filteredSegments = []
        
        do {
            let scheduleService = ScheduleBetweenStationsService(
                client: client,
                apikey: apiKey
            )
            
            let schedule = try await scheduleService.getScheduleBetweenStations(
                from: fromCode,
                to: toCode,
                date: nil,
                transportTypes: nil,
                limit: 10
            )
            
            
            guard let fetchedSegments = schedule.segments else {
                errorMessage = "Нет доступных рейсов"
                isLoading = false
                return
            }
            
            var displaySegments: [ScheduleSegmentDisplay] = []
            
            for segment in fetchedSegments.prefix(10) {
                var carrierLogoURL: String?
                
                if let carrierCode = segment.thread?.carrier?.code {
                    do {
                        let carrierService = CarrierInfoService(
                            client: client,
                            apikey: apiKey
                        )
                        
                        let carrierInfo = try await carrierService.getCarrierInfo(
                            code: String(carrierCode),
                            system: "yandex"
                        )
                        
                        carrierLogoURL = carrierInfo.carriers?.first?.logo
                    } catch {
                        print("Error loading carrier info: \(error)")
                    }
                }
                
                let displaySegment = ScheduleSegmentDisplay(
                    segment: segment,
                    carrierLogoURL: carrierLogoURL
                )
                displaySegments.append(displaySegment)
            }
            
            allSegments = displaySegments
            applyFilters()
            isLoading = false
            
        } catch {
            let errorType = determineErrorType(error)
            switch errorType {
            case .noInternet:
                errorMessage = String(localized: "error_no_internet")
            case .timeout:
                errorMessage = String(localized: "error_timeout")
            case .serverError, .other:
                errorMessage = "Ошибка загрузки расписания: \(error.localizedDescription)"
            }
            isLoading = false
            print("Error loading schedule: \(error)")
        }
    }
    
    func applyFilters() {
        if filterSettings.hasActiveFilters {
            filteredSegments = allSegments.filter { segment in
                filterSettings.matches(segment: segment)
            }
        } else {
            filteredSegments = allSegments
        }
    }
    
    func updateFilters(_ newFilters: FilterSettings) {
        filterSettings = newFilters
        applyFilters()
    }
}
