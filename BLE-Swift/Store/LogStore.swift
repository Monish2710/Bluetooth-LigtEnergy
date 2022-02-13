

import Foundation

class LogStore {
    
    static private var logs = [String]()
    
    class func append(_ log: String) {
        logs.append(log)
    }
    
    class func getAllLogs() -> [String] {
        return logs
    }
}
