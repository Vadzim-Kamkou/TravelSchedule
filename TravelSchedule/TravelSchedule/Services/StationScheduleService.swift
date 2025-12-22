import OpenAPIRuntime
import OpenAPIURLSession

protocol StationScheduleServiceProtocol {
    func getStationSchedule(
        station: String,
        date: String?,
        transportTypes: String?,
        event: String?,
        direction: String?
    ) async throws -> StationSchedule
}

actor StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getStationSchedule(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil,
        direction: String? = nil
    ) async throws -> StationSchedule {
        
        let response = try await client.getStationSchedule(query: .init(
            apikey: apikey,
            station: station,
            lang: "ru_RU",
            format: nil,
            date: date,
            transport_types: transportTypes,
            event: event,
            direction: direction,
            system: nil,
            result_timezone: nil
        ))
        return try await response.ok.body.json
    }
}
