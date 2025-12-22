import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol CarrierInfoServiceProtocol {
    func getCarrierInfo(
        code: String,
        system: String?
    ) async throws -> CarrierInfo
}

actor CarrierInfoService: CarrierInfoServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCarrierInfo(
        code: String,
        system: String? = nil
    ) async throws -> CarrierInfo {
        
        let response = try await client.getCarrierInfo(query: .init(
            apikey: apikey,
            code: code,
            system: system,
            lang: "ru_RU",
            format: nil
        ))
        return try await response.ok.body.json
    }
}
