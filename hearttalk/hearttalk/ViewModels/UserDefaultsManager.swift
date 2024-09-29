
import Foundation
import SystemConfiguration

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let isShowTipKey: String = "isShowTip"
    private let CFBundleShortVersionKey: String = "CFBundleShortVersionString"
    private let isShowAgeAlertKey: String = "isShowAgeAlert"
    private let isVibrationsKey: String = "isVibrations"
    private let isSoundsKey: String = "isSounds"
    private let isDailyCardKey: String = "isDailyCard"
    private let AppleLanguageKey: String = "AppleLanguage"
    private let isDarkModeKey: String = "isDarkMode"
    private let hasImportedDataKey: String = "hasImportedData"
    private let hasValidDataKey: String = "hasImportedData"
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?[CFBundleShortVersionKey] as? String {
            return version
        }
        return "1.0"
    }
    var isShowTip: Bool {
        get {
            if UserDefaults.standard.object(forKey: isShowTipKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isShowTipKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isShowTipKey)
        }
    }
    var isShowAgeAlert: Bool {
        get {
            if UserDefaults.standard.object(forKey: isShowAgeAlertKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isShowAgeAlertKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isShowAgeAlertKey)
        }
    }
    var isVibrations: Bool {
        get {
            if UserDefaults.standard.object(forKey: isVibrationsKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isVibrationsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isVibrationsKey)
        }
    }
    var isSounds: Bool {
        get {
            if UserDefaults.standard.object(forKey: isSoundsKey) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: isSoundsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isSoundsKey)
        }
    }
    var isDailyCard: Bool {
        get {
            if UserDefaults.standard.object(forKey: isDailyCardKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isDailyCardKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isDailyCardKey)
        }
    }
    var language: String {
        get {
            return UserDefaults.standard.string(forKey: AppleLanguageKey) ?? "en"
        }
        set {
            if UserDefaults.standard.string(forKey: AppleLanguageKey) ?? "en" != newValue {
                UserDefaults.standard.set(newValue, forKey: AppleLanguageKey)
                self.hasValidData = false
            }
        }
    }
    var isDarkMode: Bool {
        get {
            if UserDefaults.standard.object(forKey: isDarkModeKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: isDarkModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isDarkModeKey)
        }
    }
    var hasImportedData: Bool {
        get {
            if UserDefaults.standard.object(forKey: hasImportedDataKey) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: hasImportedDataKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasImportedDataKey)
        }
    }
    var hasValidData: Bool {
        get {
            if UserDefaults.standard.object(forKey: hasValidDataKey) == nil {
                return false
            }
            return UserDefaults.standard.bool(forKey: hasValidDataKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasValidDataKey)
        }
    }
    var appleLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: AppleLanguageKey) ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppleLanguageKey)
        }
    }
    
}
