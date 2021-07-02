import Foundation
import UIKit

struct QiitaStruct: Codable {
    let title: String
    let url: String
    let user: User
    struct User: Codable {
        var id: String
        var profile_image_url: String
    }
}
