import SwiftUI
import OpenAPIURLSession

// MARK: - Selection Mode
enum SelectionMode {
    case departure
    case arrival
    
    var title: String {
        switch self {
        case .departure: return String(localized: "city_selection_title")
        case .arrival: return String(localized: "city_selection_title")
        }
    }
}

// MARK: - City Selection View
struct CitySelectionView: View {
    let mode: SelectionMode
    
    @Binding var allStationsData: AllStations?
    
    let onComplete: (Settlement, Station) -> Void
    
    @State private var searchText: String = ""
    @State private var allSettlements: [Settlement] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var errorType: NetworkErrorType? = nil
    
    @FocusState private var isSearchFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    private let predefinedCityNames: [String] = [
        "Минск",
        "Могилёв",
        "Москва",
        "Санкт-Петербург",
        "Екатеринбург",
        "Новосибирск",
        "Казань"
    ]
    
    private var predefinedSettlements: [Settlement] {
        predefinedCityNames.compactMap { cityName in
            allSettlements.first { settlement in
                settlement.title == cityName
            }
        }
    }
    
    private var displayedSettlements: [Settlement] {
        if searchText.isEmpty {
            return predefinedSettlements
        } else {
            return allSettlements
                .filter { settlement in
                    guard let title = settlement.title else { return false }
                    return title.lowercased().hasPrefix(searchText.lowercased())
                }
                .sorted { settlement1, settlement2 in
                    (settlement1.title ?? "") < (settlement2.title ?? "")
                }
        }
    }
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage, let type = errorType {
                errorView(type: type, message: error)
            } else {
                contentView
            }
        }
        .background(Color.appWhite)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if allStationsData != nil {
                prepareSettlements()
            } else {
                loadAllStations()
            }
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("loading_stations")
                .font(.system(size: 17))
                .foregroundColor(.appBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appWhite)
    }
    
    @ViewBuilder
    private func errorView(type: NetworkErrorType, message: String) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                Image(type.imageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(70)
                    .frame(width: 223, height: 223)
                
                Text(LocalizedStringKey(type.titleKey))
                    .font(.system(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.appBlack)
                
                if type == .other {
                    Text(message)
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Button("try_again") {
                    errorMessage = nil
                    errorType = nil
                    loadAllStations()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 50)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            SearchBar(
                text: $searchText,
                isFocused: $isSearchFocused
            )
            
            if displayedSettlements.isEmpty {
                VStack {
                    Spacer()
                    Text("city_not_found")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.appBlack)
                    Spacer()
                }
            } else {
                List {
                    ForEach(displayedSettlements, id: \.codes?.yandex_code) { settlement in
                        ZStack {
                            NavigationLink {
                                StationSelectionView(
                                    selectedSettlement: settlement,
                                    mode: mode,
                                    onComplete: onComplete
                                )
                            } label: { EmptyView() }
                                .opacity(0)
                            
                            CityRow(settlement: settlement)
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
    }
    
    private func loadAllStations() {
        isLoading = true
        errorMessage = nil
        
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
                
                let stations = try await service.getAllStations()
                
                await MainActor.run {
                    allStationsData = stations
                    prepareSettlements()
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorType = determineErrorType(error)
                    errorMessage = error.localizedDescription
                }
                print("Error loading stations: \(error)")
            }
        }
    }
    
    private func prepareSettlements() {
        guard let allStations = allStationsData else { return }
        
        var result: [Settlement] = []
        
        allStations.countries?.forEach { country in
            country.regions?.forEach { region in
                if let settlements = region.settlements {
                    result.append(contentsOf: settlements)
                }
            }
        }
        
        allSettlements = result
    }
}

// MARK: - City Row
struct CityRow: View {
    let settlement: Settlement
    
    var body: some View {
        HStack {
            Text(settlement.title ?? "")
                .font(.system(size: 17))
                .foregroundColor(.appBlack)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 20) .bold())
                .foregroundColor(.appBlack)
        }
        .contentShape(Rectangle())
        .background(Color.appWhite)
    }
}
