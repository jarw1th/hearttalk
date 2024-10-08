
import Foundation

enum Localization {
    
    static let defaultPack: String = .localized("defaultPacks", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let simple: String = .localized("simple", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let simpleDesc: String = .localized("simpleDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let couples: String = .localized("couples", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let couplesDesc: String = .localized("couplesDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let close: String = .localized("close", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let closeDesc: String = .localized("closeDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let closer: String = .localized("closer", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let closerDesc: String = .localized("closerDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let closest: String = .localized("closest", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let to: String = .localized("to", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let color: String = .localized("color", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let closestDesc: String = .localized("closestDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let adult: String = .localized("18+", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let adultAlertTitle: String = .localized("adultAlertTitle", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let adultAlertMessage: String = .localized("adultAlertMessage", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let confirm: String = .localized("confirm", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let taboo: String = .localized("taboo", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let tabooDesc: String = .localized("tabooDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let sex: String = .localized("sex", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let sexDesc: String = .localized("sexDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let family: String = .localized("family", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let familyDesc: String = .localized("familyDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let favorites: String = .localized("favorites", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let created: String = .localized("created", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let unsorted: String = .localized("unsorted", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let unsortedDesc: String = .localized("unsortedDesc", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let generateAction: String = .localized("generateAction", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let cards: String = .localized("cards", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let card: String = .localized("card", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let packs: String = .localized("packs", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let pack: String = .localized("pack", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let goBack: String = .localized("goBack", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs: String = .localized("whatIs", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let aboutTheApp: String = .localized("aboutTheApp", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let share: String = .localized("share", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let review: String = .localized("review", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let terms: String = .localized("terms", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let privacy: String = .localized("privacy", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let contact: String = .localized("contact", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let credential: String = .localized("credential", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let checkOut: String = .localized("checkOut", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let version: String = .localized("version", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let createPack: String = .localized("createPack", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let createCard: String = .localized("createCard", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let name: String = .localized("name", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let question: String = .localized("question", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let create: String = .localized("create", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let thatIsAll: String = .localized("thatIsAll", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let prompt: String = .localized("prompt", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let generateNoun: String = .localized("generateNoun", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let clear: String = .localized("clear", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs1Header: String = .localized("whatIs1Header", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs1Name: String = .localized("whatIs1Name", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs2Header: String = .localized("whatIs2Header", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs2Name: String = .localized("whatIs2Name", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs3Header: String = .localized("whatIs3Header", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs3Name: String = .localized("whatIs3Name", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs4Header: String = .localized("whatIs4Header", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let whatIs4Name: String = .localized("whatIs4Name", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let deleting: String = .localized("deleting", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let delete: String = .localized("delete", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let cancel: String = .localized("cancel", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let perfect: String = .localized("perfect", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let empty: String = .localized("empty", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let description: String = .localized("description", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let descriptionPlaceholder: String = .localized("descriptionPlaceholder", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let notePlaceholder: String = .localized("notePlaceholder", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let notes: String = .localized("notes", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let createNote: String = .localized("createNote", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let settings: String = .localized("settings", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let vibrations: String = .localized("vibrations", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let sounds: String = .localized("sounds", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let packActionSheetTitle: String = .localized("packActionSheetTitle", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let packActionSheetMessage: String = .localized("packActionSheetMessage", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let languageActionSheetTitle: String = .localized("languageActionSheetTitle", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let languageActionSheetMessage: String = .localized("languageActionSheetMessage", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let dailyCard: String = .localized("dailyCard", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let dailyWidgetPlaceholder: String = .localized("dailyWidgetPlaceholder", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let dailyWidgetNoCard: String = .localized("dailyWidgetNoCard", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let darkMode: String = .localized("darkMode", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let alert: String = .localized("alert", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let alertCard: String = .localized("alertCard", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let alertPack: String = .localized("alertPack", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let alertNote: String = .localized("alertNote", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let deletingCard: String = .localized("deletingCard", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let deletingNote: String = .localized("deletingNote", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let addCard: String = .localized("addCard", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let addPack: String = .localized("addPack", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let addCardSub: String = .localized("addCardSub", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    static let addPackSub: String = .localized("addPackSub", language: UserDefaults.standard.string(forKey: "AppleLanguage"))
    
}
