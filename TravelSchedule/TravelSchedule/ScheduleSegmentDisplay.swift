import Foundation

struct ScheduleSegmentDisplay: Identifiable {
    let id = UUID()
    let carrierName: String
    let carrierLogoURL: String?
    let hasTransfers: Bool
    let departureDate: String
    let departureTime: String
    let arrivalTime: String
    let duration: String
    
    // Initializer для API данных
    init(segment: Components.Schemas.Segment, carrierLogoURL: String?) {
        self.carrierName = segment.thread?.carrier?.title ?? String(localized: "unknown_carrier")
        self.carrierLogoURL = carrierLogoURL
        self.hasTransfers = false
        
        // Форматируем время отправления (API возвращает "06:55:00")
        if let departureString = segment.departure {
            self.departureTime = Self.formatTime(departureString)
        } else {
            self.departureTime = ""
        }
        
        // Форматируем время прибытия
        if let arrivalString = segment.arrival {
            self.arrivalTime = Self.formatTime(arrivalString)
        } else {
            self.arrivalTime = ""
        }
        
        // Форматируем длительность
        if let durationSeconds = segment.duration {
            self.duration = Self.formatDuration(durationSeconds)
        } else {
            self.duration = ""
        }
        
        // Используем текущую дату (так как API не возвращает дату в сегменте)
        self.departureDate = Self.formatCurrentDate()
    }
    
    // Initializer для моковых данных
    init(carrierName: String, carrierLogoURL: String?, hasTransfers: Bool, departureDate: String, departureTime: String, arrivalTime: String, duration: String) {
        self.carrierName = carrierName
        self.carrierLogoURL = carrierLogoURL
        self.hasTransfers = hasTransfers
        self.departureDate = departureDate
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.duration = duration
    }
    
    // Форматирует "06:55:00" → "06:55"
    private static func formatTime(_ timeString: String) -> String {
        let components = timeString.components(separatedBy: ":")
        if components.count >= 2 {
            return "\(components[0]):\(components[1])"
        }
        return timeString
    }
    
    // Возвращает текущую дату в формате "28 ноября"
    private static func formatCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    // Форматирует секунды → "3 часа"
    private static func formatDuration(_ seconds: Int) -> String {
        let hours = Int(round(Double(seconds) / 3600.0))
        return String(format: NSLocalizedString("hours_count %lld", comment: ""), hours)    }
}

// MARK: - Mock Data для Preview

extension ScheduleSegmentDisplay {
    static var mock: ScheduleSegmentDisplay {
        ScheduleSegmentDisplay(
            carrierName: "РЖД",
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
            carrierLogoURL: nil,
            hasTransfers: false,
            departureDate: "30 ноября",
            departureTime: "14:15",
            arrivalTime: "16:45",
            duration: "3 часа"
        )
    }
}
