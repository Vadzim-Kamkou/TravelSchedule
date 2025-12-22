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
    
    private let scheduleService: ScheduleBetweenStationsService
    private let carrierService: CarrierInfoService
    
//    private let client: Client
//    private let apiKey: String
    
    var segments: [ScheduleSegmentDisplay] {
        filteredSegments
    }
    
    init() {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            let apiKey = APIConfiguration.apiKey
            
            self.scheduleService = ScheduleBetweenStationsService(
                client: client,
                apikey: apiKey
            )
            self.carrierService = CarrierInfoService(
                client: client,
                apikey: apiKey
            )
        } catch {
            fatalError("Failed to initialize services: \(error)")
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
            
            let displaySegments = await withTaskGroup(
                of: ScheduleSegmentDisplay?.self,
                returning: [ScheduleSegmentDisplay].self
            ) { group in
                for segment in fetchedSegments.prefix(10) {
                    group.addTask {
                        var carrierLogoURL: String?
                        
                        if let carrierCode = segment.thread?.carrier?.code {
                            do {
                                let carrierInfo = try await self.carrierService.getCarrierInfo(
                                    code: String(carrierCode),
                                    system: "yandex"
                                )
                                carrierLogoURL = carrierInfo.carriers?.first?.logo
                            } catch {
                                print("Error loading carrier info: \(error)")
                            }
                        }
                        
                        return await ScheduleSegmentDisplay(
                            segment: segment,
                            carrierLogoURL: carrierLogoURL
                        )
                    }
                }
                
                var results: [ScheduleSegmentDisplay] = []
                for await result in group {
                    if let segment = result {
                        results.append(segment)
                    }
                }
                return results
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
