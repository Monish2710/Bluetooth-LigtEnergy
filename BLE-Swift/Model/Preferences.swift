

import Foundation

struct Preferences: Codable {
    var needFilter: Bool
    var filter: Int
    
    init() {
        self.needFilter = false
        filter = -90
    }
}
