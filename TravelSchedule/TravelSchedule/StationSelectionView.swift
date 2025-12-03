import SwiftUI

// MARK: - Station Selection View
struct StationSelectionView: View {
    let selectedSettlement: Settlement
    let mode: SelectionMode
    let onComplete: (Settlement, Station) -> Void
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    private var allStations: [Station] {
        selectedSettlement.stations ?? []
    }
    
    private var displayedStations: [Station] {
        if searchText.isEmpty {
            return allStations
        } else {
            return allStations.filter { station in
                guard let title = station.title else { return false }
                return title.lowercased().hasPrefix(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {

            SearchBar(
                text: $searchText,
                isFocused: $isSearchFocused
            )
            
            if displayedStations.isEmpty {
                
                VStack {
                    Spacer()
                    Text("station_not_found")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.appBlack)
                    Spacer()
                }
                
            } else {
                List {
                    ForEach(Array(displayedStations.enumerated()), id: \.offset) { index, station in
                        Button {
                            onComplete(selectedSettlement, station)
                            
                        } label: {
                            StationRow(station: station)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("Загружен город: \(selectedSettlement.title ?? "N/A")")
            print("Станций: \(allStations.count)")
        }
    }
    
    private var navigationTitle: String {
        return String(localized: "station_selection_title")
    }
}

// MARK: - Station Row
struct StationRow: View {
    let station: Station
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.title ?? "")
                    .font(.system(size: 17))
                    .foregroundColor(.appBlack)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
