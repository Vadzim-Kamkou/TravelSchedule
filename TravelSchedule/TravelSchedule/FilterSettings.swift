import SwiftUI

struct FilterSettings: Equatable {
    var selectedTimes: Set<DepartureTime> = []
    var showTransfers: TransferOption = .yes
    
    var hasActiveFilters: Bool {
        !selectedTimes.isEmpty || showTransfers != .no
    }
    
    func matchesTimeFilter(_ timeString: String) -> Bool {
        
        guard !selectedTimes.isEmpty else { return true }
        
        let components = timeString.components(separatedBy: ":")
        guard components.count >= 2,
              let hour = Int(components[0]) else {
            return true
        }
        
        for timeFilter in selectedTimes {
            switch timeFilter {
            case .morning:
                if hour >= 6 && hour < 12 { return true }
            case .afternoon:
                if hour >= 12 && hour < 18 { return true }
            case .evening:
                if hour >= 18 && hour < 24 { return true }
            case .night:
                if hour >= 0 && hour < 6 { return true }
            }
        }
        
        return false
    }
    
    // Проверяет, соответствует ли рейс фильтру пересадок
    func matchesTransferFilter(_ hasTransfers: Bool) -> Bool {
        switch showTransfers {
        case .yes:
            return true
        case .no:
            return !hasTransfers
        }
    }
    
    // Проверяет, соответствует ли сегмент всем активным фильтрам
    func matches(segment: ScheduleSegmentDisplay) -> Bool {
        let timeMatch = matchesTimeFilter(segment.departureTime)
        let transferMatch = matchesTransferFilter(segment.hasTransfers)
        return timeMatch && transferMatch
    }
}

enum DepartureTime: String, CaseIterable, Identifiable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    
    var id: String { rawValue }
    
    var displayText: String {
        switch self {
        case .morning: return String(localized: "filter_morning")
        case .afternoon: return String(localized: "filter_afternoon")
        case .evening: return String(localized: "filter_evening")
        case .night: return String(localized: "filter_night")
        }
    }
}

enum TransferOption: String, CaseIterable, Identifiable {
    case yes = "yes"
    case no = "no"
    
    var id: String { rawValue }
    
    var displayText: String {
        switch self {
        case .yes: return String(localized: "filter_transfer_yes")
        case .no: return String(localized: "filter_transfer_no")
        }
    }
}
