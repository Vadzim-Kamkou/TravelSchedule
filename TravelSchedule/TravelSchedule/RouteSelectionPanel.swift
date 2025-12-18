import SwiftUI

struct RouteSelectionPanel: View {

    @Binding var departureSettlement: Settlement?
    @Binding var departureStation: Station?
    @Binding var arrivalSettlement: Settlement?
    @Binding var arrivalStation: Station?
    

    var onDepartureFieldTap: () -> Void
    var onArrivalFieldTap: () -> Void
    var onSearchTap: () -> Void
    
    private var bothStationsSelected: Bool {
        departureStation != nil && arrivalStation != nil
    }
    
    var body: some View {
           VStack(spacing: 16) {

               ZStack(alignment: .trailing) {

                   VStack(spacing: 0) {

                       RouteFieldView(
                            placeholder: String(localized: "from_placeholder"),
                            selectedSettlement: departureSettlement,
                            selectedStation: departureStation
                       )
                       .contentShape(Rectangle())
                       .onTapGesture {
                           onDepartureFieldTap()
                       }
                       
  
                       RouteFieldView(
                            placeholder: String(localized: "to_placeholder"),
                            selectedSettlement: arrivalSettlement,
                            selectedStation: arrivalStation
                       )
                       .contentShape(Rectangle())
                       .onTapGesture {
                           onArrivalFieldTap()
                       }
                   }
                   .background(Color.appWhiteUniversal)
                   .cornerRadius(16)
                   .padding(.leading, 16)
                   .padding(.trailing, 16+36+16)
                   .padding(.top, 16)
                   .padding(.bottom, 16)
                   
                   Spacer()
                   
                   SwapButton {
                       withAnimation(.easeInOut(duration: 0.3)) {
                           swap(&departureSettlement, &arrivalSettlement)
                           swap(&departureStation, &arrivalStation)
                       }
                   }
                   .padding(.trailing, 16)
               }
               .background(Color.appBlueUniversal)
               .cornerRadius(20)
               
               if bothStationsSelected {
                   Button {
                       onSearchTap()
                   } label: {
                       Text("search_button")
                           .font(.system(size: 17, weight: .semibold))
                           .foregroundStyle(.white)
                           .frame(width: 150, height: 60)
                           .background(Color.appBlueUniversal)
                           .cornerRadius(16)
                   }
                   .transition(.move(edge: .top).combined(with: .opacity))
               }
           }
           .padding(.horizontal, 16) 
       }
   }

struct RouteFieldView: View {
    let placeholder: String
    let selectedSettlement: Settlement?
    let selectedStation: Station?
    
    private var displayText: String {
        if let settlement = selectedSettlement, let station = selectedStation {
            return "\(settlement.title ?? "") (\(station.title ?? ""))"
        }
        return placeholder
    }
    
    private var isSelected: Bool {
        selectedSettlement != nil && selectedStation != nil
    }
    
    var body: some View {
        HStack {
            Text(displayText)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(isSelected ? .appBlackUniversal : .appGrayUniversal.opacity(0.5))
                .lineLimit(1)
            
            Spacer()
        }
        .padding(16)
    }
}

struct SwapButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.appWhiteUniversal)
                    .frame(width: 36, height: 36)
                Image("mainChangeIcon")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
            }
        }
        .buttonStyle(.plain)
    }
}
