
import Foundation

final class AppData {
    
    // Yandex Ad
    private(set) var homeScreenAdId: String
    private(set) var packsScreenAdId: String
    
    // Alert
    private(set) var alertMessage: String
    private(set) var alertTitle: String
    private(set) var isShowAlert: Bool
    
    // System
    private(set) var isUpdateContent: Bool
    
    init(_ data: AppDataProperties) {
        self.homeScreenAdId = data.homeScreenAdId
        self.packsScreenAdId = data.packsScreenAdId
        self.alertMessage = data.alertMessage
        self.alertTitle = data.alertTitle
        self.isShowAlert = data.isShowAlert
        self.isUpdateContent = data.isUpdateContent
    }
    
}

struct AppDataProperties {
    
    // Yandex Ad
    var homeScreenAdId: String = ""
    var packsScreenAdId: String = ""
    
    // Alert
    var alertMessage: String = ""
    var alertTitle: String = ""
    var isShowAlert: Bool = false
    
    // System
    var isUpdateContent: Bool = false
    
    init() {}
    
}
