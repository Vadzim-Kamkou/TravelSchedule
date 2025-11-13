import OpenAPIRuntime
import OpenAPIURLSession

typealias ScheduleSegments = Components.Schemas.Segments

protocol ScheduleBetweenStationsServiceProtocol {
  func getScheduleBetweenStations(
    from: String,
    to: String,
    date: String?,
    transportTypes: String?,
    limit: Int?
  ) async throws -> ScheduleSegments
}

final class ScheduleBetweenStationsService: ScheduleBetweenStationsServiceProtocol {
  private let client: Client
  private let apikey: String
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
  
  func getScheduleBetweenStations(
    from: String,
    to: String,
    date: String? = nil,
    transportTypes: String? = nil,
    limit: Int? = nil
  ) async throws -> ScheduleSegments {

    let response = try await client.getScheduleBetweenStations(query: .init(
        apikey: apikey,
        from: from,
        to: to,
        format: nil,
        lang: "ru_RU",
        date: date,
        transport_types: transportTypes,
        offset: nil,
        limit: limit,
        result_timezone: nil,
        transfers: nil
    ))
    return try response.ok.body.json
  }
}

// Test function
func testFetchScheduleBetweenStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = ScheduleBetweenStationsService(
                client: client,
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
            )
            
            print("> TEST testFetchScheduleBetweenStations")
            
            let schedule = try await service.getScheduleBetweenStations(
                from: "s9614138",
                to: "s9613989",
                date: nil,
                transportTypes: "train",
                limit: 10
            )
            
            print("SUCCESSFULLY fetched schedule")
            print("Total segments: \(schedule.segments?.count ?? 0)")
            
            if let firstSegment = schedule.segments?.first {
                print("First departure: \(firstSegment.departure ?? "N/A")")
                print("First arrival: \(firstSegment.arrival ?? "N/A")")
            }
        } catch {
            print("Error fetching schedule: \(error)")
        }
    }
}
