import SwiftUI
import OpenAPIURLSession

struct MainView: View {
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(named: "appBlack") ?? UIColor.black
    }
    
    
    
    // MARK: - State Route
    @State private var departureSettlement: Settlement? = nil
    @State private var departureStation: Station? = nil
    @State private var arrivalSettlement: Settlement? = nil
    @State private var arrivalStation: Station? = nil
    @State private var allStationsData: AllStations? = nil
    @State private var isLoadingStations = false
    
    
    // MARK: - Navigation State
    @State private var showDepartureSelection = false
    @State private var showArrivalSelection = false
    @State private var showScheduleList = false
    
    
    var body: some View {
        NavigationStack {
            TabView {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.top)
                    
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
                    Color.white.edgesIgnoringSafeArea(.top)
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
                    .foregroundColor(.gray.opacity(1))
                    .padding(.bottom, 49),
                alignment: .bottom
            )
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
        }
        .tint(.appBlack)
        .onAppear {
            //testAllServices()
            loadAllStationsIfNeeded()
        }
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
                }
            } catch {
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
            .foregroundColor(.white)
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
