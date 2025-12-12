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

final class NearestCityService: NearestCityServiceProtocol {
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
    return try response.ok.body.json
  }
}

// Test function
func testFetchNearestCity() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = NearestCityService(
                client: client,
                apikey: APIConfiguration.apiKey
            )
            
            print("> TEST testFetchNearestCity")
            
            let city = try await service.getNearestCity(
                lat: 53.9,
                lng: 30.4,
                distance: 50
            )
            
            print("SUCCESSFULLY fetched nearest city:")
            print("Title: \(city.title ?? "N/A")")
            print("Popular title: \(city.popular_title ?? "N/A")")
            print("Short title: \(city.short_title ?? "N/A")")
            print("Code: \(city.code ?? "N/A")")
            
            if let distance = city.distance {
                print("Distance: \(String(format: "%.2f", distance)) km")
            }
            
            if let lat = city.lat, let lng = city.lng {
                print("Coordinates: \(lat), \(lng)")
            }
            
        } catch {
            // Print Error
            print("Error fetching nearest city: \(error)")
        }
    }
}
