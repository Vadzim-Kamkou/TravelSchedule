import SwiftUI

struct ScheduleCardView: View {
    let segment: ScheduleSegmentDisplay
    @State private var showCarrierInfo = false
    
    var body: some View {
        Button {
            if segment.carrierCode != nil {
                showCarrierInfo = true
            }
        } label: {
            VStack {
                Spacer()
                
                VStack(spacing: 4) {
                    HStack(alignment: .top, spacing: 0) {
                        if let logoURL = segment.carrierLogoURL,
                           let url = URL(string: logoURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    CarrierPlaceholder()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 38, height: 38)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                case .failure:
                                    CarrierPlaceholder()
                                @unknown default:
                                    CarrierPlaceholder()
                                }
                            }
                        } else {
                            CarrierPlaceholder()
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(segment.carrierName)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.appBlackUniversal)
                                .lineLimit(1)
                            
                            if segment.hasTransfers {
                                Text("with_transfer")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        Text(segment.departureDate)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.appBlackUniversal)
                    }
                    .frame(height: 38)
                    
                    HStack(spacing: 0) {
                        Text(segment.departureTime)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.appBlackUniversal)
                            .fixedSize()
                        
                        Rectangle()
                            .fill(Color.appGrayUniversal)
                            .frame(height: 1)
                            .padding(.horizontal, 4)
                        
                        Text(segment.duration)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.appBlackUniversal)
                            .fixedSize()
                        
                        Rectangle()
                            .fill(Color.appGrayUniversal)
                            .frame(height: 1)
                            .padding(.horizontal, 4)
                        
                        Text(segment.arrivalTime)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.appBlackUniversal)
                            .fixedSize()
                    }
                    .frame(height: 48)
                }
                .frame(height: 90)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
            .frame(height: 104)
            .background(Color.appLightGrayUniversal)
            .cornerRadius(24)
        }
        .buttonStyle(.plain)
        .navigationDestination(isPresented: $showCarrierInfo) {
            if let carrier = segment.carrier {
                CarrierInfoView(carrier: carrier)
            }
        }
    }
}

struct CarrierPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appGrayUniversal.opacity(0.3))
                .frame(width: 38, height: 38)
            
            Image(systemName: "airplane")
                .font(.system(size: 20))
                .foregroundColor(.appGrayUniversal)
        }
    }
}

// MARK: - Preview

#Preview("Обычный рейс") {
    VStack(spacing: 12) {
        ScheduleCardView(segment: .mock)
    }
    .padding()
    .background(Color.white)
}

#Preview("С пересадкой и логотипом") {
    VStack(spacing: 12) {
        ScheduleCardView(segment: .mockWithTransfer)
    }
    .padding()
    .background(Color.white)
}

#Preview("Длинное название") {
    VStack(spacing: 12) {
        ScheduleCardView(segment: .mockLongName)
    }
    .padding()
    .background(Color.white)
}

#Preview("Список карточек") {
    ScrollView {
        VStack(spacing: 12) {
            ScheduleCardView(segment: .mock)
            ScheduleCardView(segment: .mockWithTransfer)
            ScheduleCardView(segment: .mockLongName)
            ScheduleCardView(segment: .mock)
        }
        .padding()
    }
    .background(Color.white)
}
