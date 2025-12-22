import OpenAPIRuntime
import OpenAPIURLSession

protocol NearestStationsServiceProtocol {
  func getNearestStations(lat: Double, lng: Double, distance: Int
  ) async throws -> NearestStations
}

actor NearestStationsService: NearestStationsServiceProtocol {
  private let client: Client
  private let apikey: String
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
  
  func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {

    let response = try await client.getNearestStations(query: .init(
        apikey: apikey,
        lat: lat,
        lng: lng,
        distance: distance
    ))
    return try await response.ok.body.json
  }
}

// Test function
func testFetchStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = NearestStationsService(
                client: client,
                apikey: APIConfiguration.apiKey
            )
            
            print("> TEST functestFetchStations")
            let stations = try await service.getNearestStations(
                lat: 53.9007, // 53.8910,
                lng: 30.3449 , //27.5510,
                distance: 5
            )
            
            print("SUCCESSFULLY fetched stations: \(stations)")
        } catch {
            print("Error fetching stations: \(error)")
        }
    }
}
