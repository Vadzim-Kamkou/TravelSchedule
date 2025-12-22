import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol NearestCityServiceProtocol {
    func getNearestCity(
        lat: Double,
        lng: Double,
        distance: Int?
    ) async throws -> NearestCity
}

actor NearestCityService: NearestCityServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getNearestCity(
        lat: Double,
        lng: Double,
        distance: Int? = nil
    ) async throws -> NearestCity {
        
        let response = try await client.getNearestCity(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            lang: "ru_RU",
            format: nil
        ))
        return try await response.ok.body.json
    }
}
