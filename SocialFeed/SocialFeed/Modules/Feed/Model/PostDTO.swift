import Foundation

struct PostDTO: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
