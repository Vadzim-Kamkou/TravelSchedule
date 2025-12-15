import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    @State private var showUserAgreement = false
    
    var body: some View {
        ZStack {
            Color("appWhite")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("settings_darkmode")
                        .font(.system(size: 17))
                        .foregroundColor(Color("appBlack"))
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDarkModeEnabled)
                        .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                Button(action: {
                    showUserAgreement = true
                }) {
                    HStack {
                        Text("settings_useragreement")
                            .font(.system(size: 17))
                            .foregroundColor(Color("appBlack"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20) .bold())
                            .foregroundColor(.appBlack)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text("settings_info_API")
                        .font(.system(size: 12))
                        .foregroundColor(Color("appBlack"))
                    
                    Text("settings_info_version")
                        .font(.system(size: 12))
                        .foregroundColor(Color("appBlack"))
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 64)
        .navigationDestination(isPresented: $showUserAgreement) {
            UserAgreementView()
        }
    }
}
