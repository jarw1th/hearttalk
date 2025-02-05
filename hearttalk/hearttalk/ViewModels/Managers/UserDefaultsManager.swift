
import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private var userDefaults: UserDefaults {
        if let userDefaults = UserDefaults(suiteName: "group.ruslanparastaev.hearttalk") {
            return userDefaults
        } else {
            return UserDefaults.standard
        }
    }
    private var standart: UserDefaults = UserDefaults.standard
    
    private let isOnboardedKey: String = "isOnboarded"
    private let isOnlineKey: String = "isOnline"
    private let offlineHourDateKey: String = "offlineHourDate"
    private let CFBundleShortVersionKey: String = "CFBundleShortVersionString"
    private let isShowAgeAlertKey: String = "isShowAgeAlert"
    private let isVibrationsKey: String = "isVibrations"
    private let isSoundsKey: String = "isSounds"
    private let isDailyCardKey: String = "isDailyCard"
    private let AppleLanguageKey: String = "AppleLanguage"
    private let isDarkModeKey: String = "isDarkMode"
    private let hasValidDataKey: String = "hasValidData"
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?[CFBundleShortVersionKey] as? String {
            return version
        }
        return "1.0"
    }
    var isOnboarded: Bool {
        get {
            if userDefaults.object(forKey: isOnboardedKey) == nil {
                return false
            }
            return userDefaults.bool(forKey: isOnboardedKey)
        }
        set {
            userDefaults.set(newValue, forKey: isOnboardedKey)
        }
    }
    var isOnline: Bool {
        get {
            if userDefaults.object(forKey: isOnlineKey) == nil {
                return true
            }
            return userDefaults.bool(forKey: isOnlineKey)
        }
        set {
            userDefaults.set(newValue, forKey: isOnlineKey)
        }
    }
    var offlineHourDate: Date? {
        get {
            return userDefaults.object(forKey: offlineHourDateKey) as? Date 
        }
        set {
            userDefaults.set(newValue, forKey: offlineHourDateKey)
        }
    }
    var isShowAgeAlert: Bool {
        get {
            if userDefaults.object(forKey: isShowAgeAlertKey) == nil {
                return true
            }
            return userDefaults.bool(forKey: isShowAgeAlertKey)
        }
        set {
            userDefaults.set(newValue, forKey: isShowAgeAlertKey)
        }
    }
    var isVibrations: Bool {
        get {
            if userDefaults.object(forKey: isVibrationsKey) == nil {
                return true
            }
            return userDefaults.bool(forKey: isVibrationsKey)
        }
        set {
            userDefaults.set(newValue, forKey: isVibrationsKey)
        }
    }
    var isSounds: Bool {
        get {
            if userDefaults.object(forKey: isSoundsKey) == nil {
                return false
            }
            return userDefaults.bool(forKey: isSoundsKey)
        }
        set {
            userDefaults.set(newValue, forKey: isSoundsKey)
        }
    }
    var isDailyCard: Bool {
        get {
            if userDefaults.object(forKey: isDailyCardKey) == nil {
                return true
            }
            return userDefaults.bool(forKey: isDailyCardKey)
        }
        set {
            userDefaults.set(newValue, forKey: isDailyCardKey)
        }
    }
    var language: String {
        get {
            return standart.string(forKey: AppleLanguageKey) ?? "en"
        }
        set {
            if standart.string(forKey: AppleLanguageKey) ?? "en" != newValue {
                standart.set(newValue, forKey: AppleLanguageKey)
            }
        }
    }
    var isDarkMode: Bool {
        get {
            if userDefaults.object(forKey: isDarkModeKey) == nil {
                return true
            }
            return userDefaults.bool(forKey: isDarkModeKey)
        }
        set {
            userDefaults.set(newValue, forKey: isDarkModeKey)
        }
    }
    var hasValidData: Bool {
        get {
            if userDefaults.object(forKey: hasValidDataKey) == nil {
                return false
            }
            return userDefaults.bool(forKey: hasValidDataKey)
        }
        set {
            userDefaults.set(newValue, forKey: hasValidDataKey)
        }
    }
    var appleLanguage: String {
        get {
            return standart.string(forKey: AppleLanguageKey) ?? "en"
        }
        set {
            standart.set(newValue, forKey: AppleLanguageKey)
        }
    }
    
}
