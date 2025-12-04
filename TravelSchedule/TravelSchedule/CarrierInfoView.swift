import SwiftUI

struct CarrierInfoView: View {
    let carrierCode: Int
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                // TODO
                Text("Carrier Code: \(carrierCode)")
                    .font(.system(size: 17))
                    .foregroundColor(.appBlack)
            }
        }
        .navigationTitle("Информация о перевозчике")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CarrierInfoView(carrierCode: 112)
    }
}
