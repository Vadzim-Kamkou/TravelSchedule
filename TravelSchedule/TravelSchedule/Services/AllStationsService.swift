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

// Test function
func testFetchAllStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = AllStationsService(
                client: client,
                apikey: APIConfiguration.apiKey
            )
            
            print("> TEST testFetchAllStations")
 
            let allStations = try await service.getAllStations()
            
            print("\nSUCCESSFULLY fetched all stations!")
            
            let countriesCount = allStations.countries?.count ?? 0
            print("Total countries: \(countriesCount)")
            
            var totalRegions = 0
            var totalSettlements = 0
            var totalStations = 0
            
            if let countries = allStations.countries {
                for country in countries {
                    let regionsCount = country.regions?.count ?? 0
                    totalRegions += regionsCount
                    
                    if let regions = country.regions {
                        for region in regions {
                            let settlementsCount = region.settlements?.count ?? 0
                            totalSettlements += settlementsCount
                            
                            if let settlements = region.settlements {
                                for settlement in settlements {
                                    totalStations += settlement.stations?.count ?? 0
                                }
                            }
                        }
                    }
                }
            }
            
            print("Total regions: \(totalRegions)")
            print("Total settlements: \(totalSettlements)")
            print("Total stations: \(totalStations)")
            
        } catch {
            print("Error fetching all stations: \(error)")
        }
    }
}
