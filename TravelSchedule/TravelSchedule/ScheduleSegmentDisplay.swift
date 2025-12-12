import Foundation

struct ScheduleSegmentDisplay: Identifiable {
    let id = UUID()
    let carrierName: String
    let carrierCode: Int?
    let carrierLogoURL: String?
    let hasTransfers: Bool
    let departureDate: String
    let departureTime: String
    let arrivalTime: String
    let duration: String
    
    init(segment: Components.Schemas.Segment, carrierLogoURL: String?) {
        self.carrierName = segment.thread?.carrier?.title ?? String(localized: "unknown_carrier")
        self.carrierCode = segment.thread?.carrier?.code

        self.carrierLogoURL = carrierLogoURL
        self.hasTransfers = false
        
        if let departureString = segment.departure {
            self.departureTime = Self.formatTime(departureString)
        } else {
            self.departureTime = ""
        }
        
        if let arrivalString = segment.arrival {
            self.arrivalTime = Self.formatTime(arrivalString)
        } else {
            self.arrivalTime = ""
        }
        
        if let durationSeconds = segment.duration {
            self.duration = Self.formatDuration(durationSeconds)
        } else {
            self.duration = ""
        }
        
        self.departureDate = Self.formatCurrentDate()
    }
    
    init(carrierName: String, carrierCode: Int?, carrierLogoURL: String?, hasTransfers: Bool, departureDate: String, departureTime: String, arrivalTime: String, duration: String) {
        self.carrierName = carrierName
        self.carrierCode = carrierCode
        self.carrierLogoURL = carrierLogoURL
        self.hasTransfers = hasTransfers
        self.departureDate = departureDate
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.duration = duration
    }
    
    private static func formatTime(_ timeString: String) -> String {
        let components = timeString.components(separatedBy: ":")
        if components.count >= 2 {
            return "\(components[0]):\(components[1])"
        }
        return timeString
    }
    
    private static func formatCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    private static func formatDuration(_ seconds: Int) -> String {
        let hours = Int(round(Double(seconds) / 3600.0))
        return String(format: NSLocalizedString("hours_count %lld", comment: ""), hours)    }
}

// MARK: - Mock Data для Preview
extension ScheduleSegmentDisplay {
    static var mock: ScheduleSegmentDisplay {
        ScheduleSegmentDisplay(
            carrierName: "РЖД",
            carrierCode: 112,
            carrierLogoURL: nil,
            hasTransfers: false,
            departureDate: "28 ноября",
            departureTime: "10:30",
            arrivalTime: "18:45",
            duration: "8 часов"
        )
    }
    
    static var mockWithTransfer: ScheduleSegmentDisplay {
        ScheduleSegmentDisplay(
            carrierName: "Аэрофлот",
            carrierCode: 26,
            carrierLogoURL: "https://yastat.net/s3/rasp/media/data/company/logo/svg/SU.svg",
            hasTransfers: true,
            departureDate: "29 ноября",
            departureTime: "06:15",
            arrivalTime: "14:20",
            duration: "8 часов"
        )
    }
    
    static var mockLongName: ScheduleSegmentDisplay {
        ScheduleSegmentDisplay(
            carrierName: "Северо-Западная Транспортная Компания",
            carrierCode: nil,
            carrierLogoURL: nil,
            hasTransfers: false,
            departureDate: "1 декабря",
            departureTime: "22:00",
            arrivalTime: "07:30",
            duration: "10 часов"
        )
    }
    
    static var mockShortTrip: ScheduleSegmentDisplay {
        ScheduleSegmentDisplay(
            carrierName: "Ласточка",
            carrierCode: nil,
            carrierLogoURL: nil,
            hasTransfers: false,
            departureDate: "30 ноября",
            departureTime: "14:15",
            arrivalTime: "16:45",
            duration: "3 часа"
        )
    }
}
