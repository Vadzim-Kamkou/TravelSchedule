import SwiftUI
import OpenAPIURLSession
import Combine

struct MainView: View {
    
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    
    @StateObject private var viewModel = MainViewModel()
    
    private let stories = Story.allStories
    
    init() {
        setupNavigationBarAppearance()
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                ZStack {
                    Color("appWhite").ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 12) {
                                ForEach(Array(stories.enumerated()), id: \.offset) { index, story in
                                    StoryCardView(
                                        story: story,
                                        isViewed: viewModel.viewedStories.contains(index)
                                    ) {
                                        viewModel.selectedStoryIndex = index
                                        viewModel.showStories = true
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .scrollIndicators(.hidden)
                        .frame(height: 188)
                        
                        RouteSelectionPanel(
                            departureSettlement: $viewModel.departureSettlement,
                            departureStation: $viewModel.departureStation,
                            arrivalSettlement: $viewModel.arrivalSettlement,
                            arrivalStation: $viewModel.arrivalStation,
                            onDepartureFieldTap: {
                                viewModel.showDepartureSelection = true
                            },
                            onArrivalFieldTap: {
                                viewModel.showArrivalSelection = true
                            },
                            onSearchTap: {
                                viewModel.showScheduleList = true
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
                    .foregroundStyle(.appBlackTransparent)
                    .padding(.bottom, 49),
                alignment: .bottom
            )
            .navigationDestination(isPresented: $viewModel.showNetworkError) {
                NetworkErrorView(errorMessage: viewModel.errorMessage ?? "Неизвестная ошибка") {
                    Task {
                        await viewModel.loadAllStationsIfNeeded()
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.showDepartureSelection) {
                CitySelectionView(
                    mode: .departure,
                    allStationsData: $viewModel.allStationsData,
                    onComplete: { settlement, station in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.departureSettlement = settlement
                            viewModel.departureStation = station
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.showDepartureSelection = false
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $viewModel.showArrivalSelection) {
                CitySelectionView(
                    mode: .arrival,
                    allStationsData: $viewModel.allStationsData,
                    onComplete: { settlement, station in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.arrivalSettlement = settlement
                            viewModel.arrivalStation = station
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.showArrivalSelection = false
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $viewModel.showScheduleList) {
                if let depSettlement = viewModel.departureSettlement,
                   let depStation = viewModel.departureStation,
                   let arrSettlement = viewModel.arrivalSettlement,
                   let arrStation = viewModel.arrivalStation {
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
        .fullScreenCover(isPresented: $viewModel.showStories) {
            StoriesView(
                initialStoryIndex: viewModel.selectedStoryIndex,
                viewedStories: $viewModel.viewedStories,
            )
        }
        .task {
            await viewModel.loadAllStationsIfNeeded()
        }
        
        .interactiveDismissDisabled(true)
        .onAppear {
            setupNavigationBarAppearance()
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
        
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(named: "appBlack")
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
                    .foregroundStyle(.appBlack)
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
