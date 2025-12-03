import Foundation
import SwiftUI
import Combine
import OpenAPIURLSession

@MainActor
class ScheduleListViewModel: ObservableObject {
    @Published var segments: [ScheduleSegmentDisplay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client: Client
    private let apiKey: String
    
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
        segments = []
        
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
            
            segments = displaySegments
            isLoading = false
            
        } catch {
            errorMessage = "Ошибка загрузки расписания: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
