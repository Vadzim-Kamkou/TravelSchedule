import OpenAPIRuntime
import OpenAPIURLSession

protocol ScheduleBetweenStationsServiceProtocol {
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String?,
        transportTypes: String?,
        limit: Int?
    ) async throws -> ScheduleSegments
}

actor ScheduleBetweenStationsService: ScheduleBetweenStationsServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getScheduleBetweenStations(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        limit: Int? = nil
    ) async throws -> ScheduleSegments {
        
        let response = try await client.getScheduleBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: nil,
            lang: "ru_RU",
            date: date,
            transport_types: transportTypes,
            offset: nil,
            limit: limit,
            result_timezone: nil,
            transfers: nil
        ))
        return try await response.ok.body.json
    }
}
