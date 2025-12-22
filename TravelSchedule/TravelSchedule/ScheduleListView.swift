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
            Color.appWhite.ignoresSafeArea()
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("loading_schedule")
                        .font(.system(size: 17))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appWhite)
                
            } else if let error = viewModel.errorMessage {
                GeometryReader { geometry in
                    VStack(spacing: 16) {
                        Spacer()
                        
                        errorImage(for: error)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 223, height: 223)
                        
                        Text("error_server_error")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(.appBlack)
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 50)
                }
                .background(Color.appWhite)
            } else if viewModel.segments.isEmpty {
                VStack {
                    Text(routeTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.appBlack)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    Spacer()
                    Text("no_options")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundStyle(.appBlack)
                    if viewModel.filterSettings.hasActiveFilters {
                    }
                    Spacer()
                }
                .background(Color.appWhite)
                
            } else {
                VStack(spacing: 0) {
                    Text(routeTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.appBlack)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                .background(Color.appWhite)
                
                VStack {
                    Spacer()
                    
                    Button {
                        showFilters = true
                    } label: {
                        HStack {
                            Text("specify_time")
                                .font(.system(size: 17, weight: .semibold))
                            
                            if viewModel.filterSettings.hasActiveFilters {
                                Circle()
                                    .fill(Color.appRedUniversal)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .foregroundStyle(.white)
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
            viewModel.applyFilters()
        }
    }
    
    private func errorImage(for error: String) -> Image {
        if error.contains("интернет") || error.contains("internet") || error.contains("соединение") {
            return Image(.errorsNoInternet)
        } else {
            return Image(.errorsServerError)
        }
    }
}
