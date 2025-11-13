import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CarrierInfo = Components.Schemas.CarrierResponse

protocol CarrierInfoServiceProtocol {
  func getCarrierInfo(
    code: String,
    system: String?
  ) async throws -> CarrierInfo
}

final class CarrierInfoService: CarrierInfoServiceProtocol {
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
    return try response.ok.body.json
  }
}

// Test function
func testFetchCarrierInfo() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )
            
            let service = CarrierInfoService(
                client: client,
                apikey: "ceea6351-f390-4784-8f66-7f6409f22768"
            )
            
            print("> TEST testFetchCarrierInfo")
            print("Getting carrier code from schedule...")
            
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
            
            guard let carrierCode = schedule.segments?.first?.thread?.carrier?.code else {
                print("Error: No carrier code found in schedule")
                return
            }
            
            print("Found carrier code: \(carrierCode)")
            
            let carrierInfo = try await service.getCarrierInfo(
                code: String(carrierCode),
                system: "yandex"
            )
            
            // Print Success
            print("\nSUCCESSFULLY fetched carrier info:")
            
            if let carriers = carrierInfo.carriers, let carrier = carriers.first {
                print("Title: \(carrier.title ?? "N/A")")
                print("Code: \(carrier.code ?? 0)")
                print("Phone: \(carrier.phone ?? "N/A")")
                print("Email: \(carrier.email ?? "N/A")")
                print("Address: \(carrier.address ?? "N/A")")
                print("URL: \(carrier.url ?? "N/A")")
                print("Logo: \(carrier.logo ?? "N/A")")
                print("Contacts: \(carrier.contacts ?? "N/A")")
            } else {
                print("No carriers found in response")
            }
        } catch {
            // Print Error
            print("Error fetching carrier info: \(error)")
        }
    }
}
