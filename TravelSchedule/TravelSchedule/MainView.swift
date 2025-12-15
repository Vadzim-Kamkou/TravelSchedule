import SwiftUI
import OpenAPIURLSession

struct MainView: View {
    
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false

    
    // MARK: - State Route
    @State private var departureSettlement: Settlement? = nil
    @State private var departureStation: Station? = nil
    @State private var arrivalSettlement: Settlement? = nil
    @State private var arrivalStation: Station? = nil
    @State private var allStationsData: AllStations? = nil
    @State private var isLoadingStations = false
    @State private var errorMessage: String? = nil
    
    // MARK: - Navigation State
    @State private var showDepartureSelection = false
    @State private var showArrivalSelection = false
    @State private var showScheduleList = false
    @State private var showNetworkError = false
    
    
    var body: some View {
        NavigationStack {
            TabView {
                ZStack {
                    Color("appWhite").ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(0..<5) { index in
                                    StoryCardView(index: index)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .frame(height: 188)
                        
                        RouteSelectionPanel(
                            departureSettlement: $departureSettlement,
                            departureStation: $departureStation,
                            arrivalSettlement: $arrivalSettlement,
                            arrivalStation: $arrivalStation,
                            onDepartureFieldTap: {
                                showDepartureSelection = true
                            },
                            onArrivalFieldTap: {
                                showArrivalSelection = true
                            },
                            onSearchTap: {
                                showScheduleList = true
                            }
                        )
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                }
                .tabItem {
                    Image(.tapBarScheduleIconPassive)
                }
                .tag(0)
                
                ZStack {
                    Color("appWhite").ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 2) {
                        SettingsView()
                            .tabItem {
                                Image(.tapBarSettingsIconPassive)
                            }
                            .tag(1)
                    }
                    .padding(.leading, 8)
                }
                .tabItem {
                    Image(.tapBarSettingsIconPassive)
                }
                .tag(1)
            }
            .tint(.appBlack)

            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.appBlackTransparent)
                    .padding(.bottom, 49),
                alignment: .bottom
            )
            .navigationDestination(isPresented: $showNetworkError) {
                NetworkErrorView(errorMessage: errorMessage ?? "Неизвестная ошибка") {
                    errorMessage = nil
                    loadAllStationsIfNeeded()
                }
            }
            .navigationDestination(isPresented: $showDepartureSelection) {
                CitySelectionView(
                    mode: .departure,
                    allStationsData: $allStationsData,
                    onComplete: { settlement, station in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            departureSettlement = settlement
                            departureStation = station
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showDepartureSelection = false
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $showArrivalSelection) {
                CitySelectionView(
                    mode: .arrival,
                    allStationsData: $allStationsData,
                    onComplete: { settlement, station in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            arrivalSettlement = settlement
                            arrivalStation = station
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showArrivalSelection = false
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $showScheduleList) {
                if let depSettlement = departureSettlement,
                   let depStation = departureStation,
                   let arrSettlement = arrivalSettlement,
                   let arrStation = arrivalStation {
                    ScheduleListView(
                        departureSettlement: depSettlement,
                        departureStation: depStation,
                        arrivalSettlement: arrSettlement,
                        arrivalStation: arrStation
                    )
                }
            }
            .toolbarBackground(Color("appWhite"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(.appBlack)
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        .onAppear {
            setupNavigationBarAppearance()
            loadAllStationsIfNeeded()
        }
    }
    
    private func setupNavigationBarAppearance() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            if let backgroundColor = UIColor(named: "appWhite") {
                appearance.backgroundColor = backgroundColor
            }
            
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor(named: "appBlack") ?? UIColor.label,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
            
            appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor(named: "appBlack")
        }
    
    private func loadAllStationsIfNeeded() {
        guard allStationsData == nil else { return }
        
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
                    errorMessage = nil
                    showNetworkError = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showNetworkError = true
                    
                }
                print("Error loading stations: \(error)")
            }
        }
    }
}

struct StoryCardView: View {
    let index: Int
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("story\(index)")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 92, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 0) {
                Text("stories_text")
            }
            .font(.system(size: 12))
            .foregroundColor(.appWhiteUniversal)
            .padding(8)
        }
        .frame(width: 92, height: 140)
    }
}

func testAllServices() {
    Task {
        print("All Service Tests...\n")
        
        print("1. Test Copyright Service")
        testFetchCopyright()
        try? await Task.sleep(for: .seconds(2))
        
        print("\n2. Test All Stations Service")
        testFetchAllStations()
        try? await Task.sleep(for: .seconds(3))
        
        print("\n3. Test Nearest City Service")
        testFetchNearestCity()
        try? await Task.sleep(for: .seconds(2))
        
        print("\n4. Test Nearest Stations Service")
        testFetchStations()
        try? await Task.sleep(for: .seconds(2))
        
        print("\n5. Test Station Schedule Service")
        testFetchStationSchedule()
        try? await Task.sleep(for: .seconds(2))
        
        print("\n6. Test Schedule Between Stations Service")
        testFetchScheduleBetweenStations()
        try? await Task.sleep(for: .seconds(2))
        
        print("\n7. Test Route Stations Service")
        testFetchRouteStations()
        try? await Task.sleep(for: .seconds(2))
        
        print("\n8. Test Carrier Info Service")
        testFetchCarrierInfo()
        try? await Task.sleep(for: .seconds(2))
        
        print("\nAll test finished!")
    }
}

struct NetworkErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(.errorsNoInternet)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 223, height: 223)
                Text("error_no_internet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appBlack)
                Button("try_again") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }
}
