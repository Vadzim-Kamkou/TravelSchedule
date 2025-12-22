import SwiftUI
import OpenAPIURLSession
import Combine

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
    
    @StateObject private var viewModel: CitySelectionViewModel
    let mode: SelectionMode
    let onComplete: (Settlement, Station) -> Void
    
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(mode: SelectionMode, allStationsData: Binding<AllStations?>, onComplete: @escaping (Settlement, Station) -> Void) {
        self.mode = mode
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: CitySelectionViewModel(allStationsData: allStationsData))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage, let type = viewModel.errorType {
                errorView(type: type, message: error)
            } else {
                contentView
            }
        }
        .background(Color.appWhite)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDataIfNeeded()
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("loading_stations")
                .font(.system(size: 17))
                .foregroundStyle(.appBlack)
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
                    .foregroundStyle(.appBlack)
                
                if type == .other {
                    Text(message)
                        .font(.system(size: 17))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Button("try_again") {
                    Task {
                        await viewModel.loadAllStations()
                    }
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
                text: $viewModel.searchText,
                isFocused: $isSearchFocused
            )
            
            if viewModel.displayedSettlements.isEmpty {
                VStack {
                    Spacer()
                    Text("city_not_found")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundStyle(.appBlack)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.displayedSettlements, id: \.codes?.yandex_code) { settlement in
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
}

// MARK: - City Row
struct CityRow: View {
    let settlement: Settlement
    
    var body: some View {
        HStack {
            Text(settlement.title ?? "")
                .font(.system(size: 17))
                .foregroundStyle(.appBlack)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 20) .bold())
                .foregroundStyle(.appBlack)
        }
        .contentShape(Rectangle())
        .background(Color.appWhite)
    }
}
