import OpenAPIRuntime
import OpenAPIURLSession

typealias RouteStations = Components.Schemas.ThreadStationsResponse

protocol RouteStationsServiceProtocol {
  func getRouteStations(
    uid: String,
    from: String?,
    to: String?,
    date: String?,
    showSystems: String?
  ) async throws -> RouteStations
}

final class RouteStationsService: RouteStationsServiceProtocol {
  private let client: Client
  private let apikey: String
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
  
  func getRouteStations(
    uid: String,
    from: String? = nil,
    to: String? = nil,
    date: String? = nil,
    showSystems: String? = nil
  ) async throws -> RouteStations {

    let response = try await client.getRouteStations(query: .init(
        apikey: apikey,
        uid: uid,
        from: from,
        to: to,
        format: nil,
        lang: "ru_RU",
        date: date,
        show_systems: showSystems
    ))
    return try response.ok.body.json
  }
}

// Test function
func testFetchRouteStations() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            print("> TEST testFetchRouteStations")
            print("Getting schedule to find a real UID...")
            
            let scheduleService = ScheduleBetweenStationsService(
                client: client,
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
            )
            
            let schedule = try await scheduleService.getScheduleBetweenStations(
                from: "s9614138",
                to: "s9613989",
                date: nil,
                transportTypes: "train",
                limit: 1
            )
            
            guard let uid = schedule.segments?.first?.thread?.uid else {
                print("Error: No UID found in schedule")
                return
            }
            
            print("Found UID: \(uid)")
            print("Thread title: \(schedule.segments?.first?.thread?.title ?? "N/A")")
            
            let routeService = RouteStationsService(
                client: client,
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
            )
            
            let route = try await routeService.getRouteStations(
                uid: uid,
                from: nil,
                to: nil,
                date: nil,
                showSystems: nil
            )
            
            // Print Success
            print("\nSUCCESSFULLY fetched route stations:")
            print("Title: \(route.title ?? "N/A")")
            print("UID: \(route.uid ?? "N/A")")
            print("Transport type: \(route.transport_type ?? "N/A")")
            print("Vehicle: \(route.vehicle ?? "N/A")")
            print("Days: \(route.days ?? "N/A")")
            print("From: \(route.from?.title ?? "N/A")")
            print("To: \(route.to?.title ?? "N/A")")
            print("Total stops: \(route.stops?.count ?? 0)")
            
            if let stops = route.stops, !stops.isEmpty {
                print("\nFirst 3 stops:")
                for (index, stop) in stops.prefix(3).enumerated() {
                    print("\n  Stop \(index + 1):")
                    print("    Station: \(stop.station?.title ?? "N/A")")
                    print("    Arrival: \(stop.arrival ?? "N/A")")
                    print("    Departure: \(stop.departure ?? "N/A")")
                    if let stopTime = stop.stop_time {
                        print("    Stop duration: \(stopTime) seconds")
                    }
                }
                
                print("\n... and \(stops.count - 3) more stops")
            }
        } catch {
            // Print Error
            print("Error fetching route stations: \(error)")
        }
    }
}
