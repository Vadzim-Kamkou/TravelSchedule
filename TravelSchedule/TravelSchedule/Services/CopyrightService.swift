import OpenAPIRuntime
import OpenAPIURLSession

protocol CopyrightServiceProtocol {
    func getCopyright() async throws -> CopyrightResponse
}

actor CopyrightService: CopyrightServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCopyright() async throws -> CopyrightResponse {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey
        ))
        return try await response.ok.body.json
    }
}
