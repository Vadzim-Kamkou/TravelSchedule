import SwiftUI

struct ScheduleListView: View {
    let departureSettlement: Settlement
    let departureStation: Station
    let arrivalSettlement: Settlement
    let arrivalStation: Station
    
    @StateObject private var viewModel = ScheduleListViewModel()
    @State private var showFilters = false
    @Environment(\.dismiss) private var dismiss
    
    private var routeTitle: String {
        let departureCity = departureSettlement.title ?? ""
        let departureStationName = departureStation.title ?? ""
        let arrivalCity = arrivalSettlement.title ?? ""
        let arrivalStationName = arrivalStation.title ?? ""
        
        return "\(departureCity)(\(departureStationName)) - \(arrivalCity)(\(arrivalStationName))"
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("loading_schedule")
                        .font(.system(size: 17))
                        .foregroundColor(.gray)
                }
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Spacer()
                    Text("error_title")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.appBlack)
                    Text(error)
                        .font(.system(size: 17))
                        .foregroundColor(.appGrayUniversal)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                }
            } else if viewModel.segments.isEmpty {
                VStack {
                    Spacer()
                    Text("no_options")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.appBlack)
                    if viewModel.filterSettings.hasActiveFilters {
                        // Разумно добавить кнопку уточнить время, чтобы изменить настройки фильтров, а не запускать поиск заново.
                    }
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    Text(routeTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appBlack)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.segments) { segment in
                                ScheduleCardView(segment: segment)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    Button {
                        showFilters = true
                    } label: {
                        HStack {
                            Text("specify_time")
                                .font(.system(size: 17, weight: .semibold))
                            
                            // Показываем индикатор активных фильтров
                            if viewModel.filterSettings.hasActiveFilters {
                                Circle()
                                    .fill(Color.appRedUniversal)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.appBlueUniversal)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showFilters) {
            FilterView(filterSettings: $viewModel.filterSettings)
        }
        .task {
            await viewModel.loadSchedule(
                from: departureStation,
                to: arrivalStation
            )
        }
        .onChange(of: viewModel.filterSettings) { oldValue, newValue in
                    // Применяем фильтры при изменении настроек
                    viewModel.applyFilters()
                }
    }
}
