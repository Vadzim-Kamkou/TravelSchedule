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

// Test function
func testFetchCopyright() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = CopyrightService(
                client: client,
                apikey: APIConfiguration.apiKey
            )
            
            print("> TEST testFetchCopyright")
            let copyright = try await service.getCopyright()
            
            print("SUCCESSFULLY fetched copyright: \(copyright)")
            
            if let copyrightData = copyright.copyright {
                print("Copyright text: \(copyrightData.text ?? "N/A")")
                print("URL: \(copyrightData.url ?? "N/A")")
            }
        } catch {
            print("Error fetching copyright: \(error)")
        }
    }
}
