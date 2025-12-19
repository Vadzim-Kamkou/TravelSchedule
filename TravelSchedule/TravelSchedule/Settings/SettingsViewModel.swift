import SwiftUI
import Combine

@Observable
final class SettingsViewModel {
    var isDarkModeEnabled: Bool {
        didSet {
            UserDefaultsService.shared.setBool(isDarkModeEnabled, forKey: UserDefaultsService.Keys.isDarkModeEnabled)
        }
    }
    
    var showUserAgreement: Bool = false
    private var cancellables = Set<AnyCancellable>()
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    var apiInfo: String {
        "Версия API Яндекс.Расписаний 3.0"
    }
    
    init() {
        self.isDarkModeEnabled = UserDefaultsService.shared.getBool(
            forKey: UserDefaultsService.Keys.isDarkModeEnabled,
            defaultValue: false
        )
        setupUserDefaultsObserver()
    }
    
    func openUserAgreement() {
        showUserAgreement = true
    }
    
    func closeUserAgreement() {
        showUserAgreement = false
    }
    
    private func setupUserDefaultsObserver() {
        UserDefaultsService.shared.boolPublisher(forKey: UserDefaultsService.Keys.isDarkModeEnabled)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                if self.isDarkModeEnabled != newValue {
                    self.isDarkModeEnabled = newValue
                }
            }
            .store(in: &cancellables)
    }
}
