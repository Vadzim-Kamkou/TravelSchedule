import SwiftUI
import OpenAPIURLSession

struct CarrierInfoView: View {
    let carrier: Components.Schemas.Carrier
    
    var body: some View {
        ZStack {
            Color.appWhite.ignoresSafeArea()
            
            VStack(spacing: 16) {
                if let logoURL = carrier.logo,
                   let url = URL(string: logoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .frame(maxWidth: .infinity, maxHeight: 104)
                                .padding(.horizontal, 16)
                        default:
                            CarrierLogoPlaceholder()
                        }
                    }
                } else {
                    CarrierLogoPlaceholder()
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    Text(carrier.title ?? "carrier_info_unknowncarrier")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.appBlack)
                        .multilineTextAlignment(.leading)
                    
                    if let email = extractedEmail {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("carrier_info_email")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.appBlack)
                            Text(email)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.appBlueUniversal)
                        }
                    }
                    
                    if let phone = extractedPhone {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("carrier_info_phone")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.appBlack)
                            
                            Text(phone)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.appBlueUniversal)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
        .navigationTitle("carrier_info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var extractedEmail: String? {
        if let email = carrier.email, !email.isEmpty {
            return email
        }
        
        if let contacts = carrier.contacts {
            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            if let regex = try? NSRegularExpression(pattern: emailPattern),
               let match = regex.firstMatch(in: contacts, range: NSRange(contacts.startIndex..., in: contacts)) {
                if let range = Range(match.range, in: contacts) {
                    return String(contacts[range])
                }
            }
        }
        
        return nil
    }
    
    private var extractedPhone: String? {
        if let phone = carrier.phone, !phone.isEmpty {
            return phone
        }
        
        if let contacts = carrier.contacts {
            let phonePattern = "\\(\\+\\d{1,4}\\s?\\d{1,4}\\)\\s?\\d{3}-\\d{2}-\\d{2}"
            if let regex = try? NSRegularExpression(pattern: phonePattern),
               let match = regex.firstMatch(in: contacts, range: NSRange(contacts.startIndex..., in: contacts)) {
                if let range = Range(match.range, in: contacts) {
                    return String(contacts[range])
                }
            }
        }
        return nil
    }
}

struct CarrierLogoPlaceholder: View {
    var body: some View {
    }
}
