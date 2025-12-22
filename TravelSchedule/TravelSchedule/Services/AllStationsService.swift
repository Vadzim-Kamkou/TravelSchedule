import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol AllStationsServiceProtocol {
    func getAllStations() async throws -> AllStations
}

actor AllStationsService: AllStationsServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getAllStations() async throws -> AllStations {
        let response = try await client.getAllStations(query: .init(
            apikey: apikey,
            lang: "ru_RU",
            format: nil
        ))
        
        var fullData = Data()
        for try await chunk in try await response.ok.body.html {
            fullData.append(contentsOf: chunk)
        }
        
        return try await Self.decodeOnMainActor(fullData)
    }
    
    @MainActor
    private static func decodeOnMainActor(_ data: Data) throws -> AllStations {
        return try JSONDecoder().decode(AllStations.self, from: data)
    }
}
