import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        ZStack {
            Color("appWhite")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("settings_darkmode")
                        .font(.system(size: 17))
                        .foregroundStyle(Color("appBlack"))
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { viewModel.isDarkModeEnabled },
                        set: { viewModel.isDarkModeEnabled = $0 }
                    ))
                    .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                Button(action: {
                    viewModel.openUserAgreement()
                }) {
                    HStack {
                        Text("settings_useragreement")
                            .font(.system(size: 17))
                            .foregroundStyle(Color("appBlack"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20).bold())
                            .foregroundStyle(.appBlack)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text(viewModel.apiInfo)
                    Text("Версия \(viewModel.appVersion)")
                }
                .font(.system(size: 12))
                .foregroundStyle(Color("appBlack"))
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 64)
        .navigationDestination(isPresented: $viewModel.showUserAgreement) {
            UserAgreementView()
        }
    }
}
