
import FirebaseRemoteConfig

class RemoteConfigManager {
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    var appData: AppData?
    
    private var isConnected: Bool

    init(_ isConnected: Bool) {
        self.isConnected = isConnected
        if isConnected {
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 3600
            remoteConfig.configSettings = settings
        }
    }

    func fetchRemoteConfig(_ completion: @escaping () -> Void) {
        remoteConfig.fetch { [weak self] status, error in
            if let error = error {
                print("Error fetching remote config: \(error)")
                return
            }

            self?.remoteConfig.activate()
            self?.getData()
            completion()
        }
    }

    private func getData() {
        var data = AppDataProperties()
        data.alertMessage = remoteConfig["alertMessage"].stringValue
        data.alertTitle = remoteConfig["alertTitle"].stringValue
        data.homeScreenAdId = remoteConfig["homeScreenAdId"].stringValue
        data.packsScreenAdId = remoteConfig["packsScreenAdId"].stringValue
        data.isShowAlert = remoteConfig["isShowAlert"].boolValue
        data.isUpdateContent = remoteConfig["isUpdateContent"].boolValue
        
        self.appData = AppData(data)
    }
    
}
