import OpenAPIRuntime
import OpenAPIURLSession

typealias CopyrightResponse = Components.Schemas.CopyrightResponse

protocol CopyrightServiceProtocol {
    func getCopyright() async throws -> CopyrightResponse
}

final class CopyrightService: CopyrightServiceProtocol {
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
        return try response.ok.body.json
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
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
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
