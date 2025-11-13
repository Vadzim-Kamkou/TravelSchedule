import OpenAPIRuntime
import OpenAPIURLSession

typealias StationSchedule = Components.Schemas.ScheduleResponse

protocol StationScheduleServiceProtocol {
  func getStationSchedule(
    station: String,
    date: String?,
    transportTypes: String?,
    event: String?,
    direction: String?
  ) async throws -> StationSchedule
}

final class StationScheduleService: StationScheduleServiceProtocol {
  private let client: Client
  private let apikey: String
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
  
  func getStationSchedule(
    station: String,
    date: String? = nil,
    transportTypes: String? = nil,
    event: String? = nil,
    direction: String? = nil
  ) async throws -> StationSchedule {

    let response = try await client.getStationSchedule(query: .init(
        apikey: apikey,
        station: station,
        lang: "ru_RU",
        format: nil,
        date: date,
        transport_types: transportTypes,
        event: event,
        direction: direction,
        system: nil,
        result_timezone: nil
    ))
    return try response.ok.body.json
  }
}

// Test function
func testFetchStationSchedule() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = StationScheduleService(
                client: client,
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
            )
            
            print("> TEST testFetchStationSchedule")
            
            let schedule = try await service.getStationSchedule(
                station: "s9614138",
                date: nil,
                transportTypes: "train",
                event: nil,
                direction: nil
            )
            
            // Print Success
            print("SUCCESSFULLY fetched station schedule:")
            print("Station: \(schedule.station?.title ?? "N/A")")
            print("Date: \(schedule.date ?? "N/A")")
            print("Total schedule items: \(schedule.schedule?.count ?? 0)")
            print("Total interval schedule items: \(schedule.interval_schedule?.count ?? 0)")
            
            if let firstScheduleItem = schedule.schedule?.first {
                print("\nFirst schedule item:")
                print("  Departure: \(firstScheduleItem.departure ?? "N/A")")
                print("  Arrival: \(firstScheduleItem.arrival ?? "N/A")")
                print("  Thread title: \(firstScheduleItem.thread?.title ?? "N/A")")
                print("  Days: \(firstScheduleItem.days ?? "N/A")")
            }
        } catch {
            // Print Error
            print("Error fetching station schedule: \(error)")
        }
    }
}
