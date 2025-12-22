import OpenAPIRuntime
import OpenAPIURLSession

protocol RouteStationsServiceProtocol {
    func getRouteStations(
        uid: String,
        from: String?,
        to: String?,
        date: String?,
        showSystems: String?
    ) async throws -> RouteStations
}

actor RouteStationsService: RouteStationsServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getRouteStations(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil,
        showSystems: String? = nil
    ) async throws -> RouteStations {
        
        let response = try await client.getRouteStations(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            format: nil,
            lang: "ru_RU",
            date: date,
            show_systems: showSystems
        ))
        return try await response.ok.body.json
    }
}
