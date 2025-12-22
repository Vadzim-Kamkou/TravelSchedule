import SwiftUI
import Combine

// MARK: - Station Selection View
struct StationSelectionView: View {
    
    @StateObject private var viewModel: StationSelectionViewModel
    
    init(selectedSettlement: Settlement, mode: SelectionMode, onComplete: @escaping (Settlement, Station) -> Void) {
        self.mode = mode
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: StationSelectionViewModel(selectedSettlement: selectedSettlement))
    }
    
    let mode: SelectionMode
    let onComplete: (Settlement, Station) -> Void
    
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            SearchBar(
                text: $viewModel.searchText,
                isFocused: $isSearchFocused
            )
            
            if viewModel.displayedStations.isEmpty {
                
                VStack {
                    Spacer()
                    Text("station_not_found")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundStyle(.appBlack)
                    Spacer()
                }
                
            } else {
                List {
                    ForEach(Array(viewModel.displayedStations.enumerated()), id: \.offset) { index, station in
                        Button {
                            onComplete(viewModel.selectedSettlement, station)
                            
                        } label: {
                            StationRow(station: station)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.appWhite)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .background(Color.appWhite)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            print("Загружен город: \(viewModel.selectedSettlement.title ?? "N/A")")
            print("Станций: \(viewModel.allStations.count)")
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
                    .foregroundStyle(.appBlack)
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
