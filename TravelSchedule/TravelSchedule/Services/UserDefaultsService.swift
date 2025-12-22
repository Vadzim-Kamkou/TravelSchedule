import Foundation
import Combine

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func set<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func get<T>(forKey key: String, defaultValue: T) -> T {
        return userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    
    func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
        if userDefaults.object(forKey: key) == nil {
            return defaultValue
        }
        return userDefaults.bool(forKey: key)
    }
    
    func getString(forKey key: String, defaultValue: String = "") -> String {
        return userDefaults.string(forKey: key) ?? defaultValue
    }
    
    func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
        if userDefaults.object(forKey: key) == nil {
            return defaultValue
        }
        return userDefaults.integer(forKey: key)
    }
    
    func publisher<T>(forKey key: String, type: T.Type) -> AnyPublisher<T?, Never> {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .compactMap { _ in
                self.userDefaults.object(forKey: key) as? T
            }
            .prepend(userDefaults.object(forKey: key) as? T) // Отправляем текущее значение сразу
            .eraseToAnyPublisher()
    }
    
    func boolPublisher(forKey key: String) -> AnyPublisher<Bool, Never> {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .map { _ in
                self.userDefaults.bool(forKey: key)
            }
            .prepend(userDefaults.bool(forKey: key))
            .removeDuplicates() 
            .eraseToAnyPublisher()
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

extension UserDefaultsService {
    enum Keys {
        static let isDarkModeEnabled = "isDarkModeEnabled"
    }
}
