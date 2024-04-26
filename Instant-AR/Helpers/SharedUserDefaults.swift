import Foundation

class SharedUserDefaults{
    static let shared = SharedUserDefaults()
        
    init() {}
    
    func set(value: Any, forKey key: String) {
        UserDefaults(suiteName: Constants.suiteName)?.set(value, forKey: key)
    }
    
    func removeValue(forKey key: String) {
        UserDefaults(suiteName: Constants.suiteName)?.removeObject(forKey: key)
    }
    
    func getValue(forKey key: String) -> Any? {
        return UserDefaults(suiteName: Constants.suiteName)?.value(forKey: key)
    }
}
