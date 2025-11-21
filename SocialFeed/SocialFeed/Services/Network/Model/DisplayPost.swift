import Foundation

struct DisplayPost {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    var isLiked: Bool
    var avatarURL: String
    
    init(from dto: PostDTO) {
        self.userId = dto.userId
        self.id = dto.id
        self.title = dto.title
        self.body = dto.body
        self.isLiked = false
        self.avatarURL = "https://picsum.photos/seed/\(userId)200/200"
    }
}
