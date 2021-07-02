import Foundation
import UIKit

struct HistoryStruct{
    var title: String
    var history: String
    /// Dictionaryから、自分自身に代入します。
    /// - Parameter dictionary: HistoryStruct型
    init(dic: [String:Any]){
        self.title = dic["title"] as? String ?? ""
        self.history = dic["history"] as? String ?? ""
    }
}
