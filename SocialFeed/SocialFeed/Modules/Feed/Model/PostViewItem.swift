import Foundation

struct PostViewItem {
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
        self.avatarURL = "https://picsum.photos/seed/\(userId)100/100"
    }
    
    init(from entity: PostEntity) {
        self.userId = Int(entity.userId)
        self.id = Int(entity.id)
        self.title = entity.title ?? String()
        self.body = entity.body ?? String()
        self.isLiked = entity.isLiked
        self.avatarURL = entity.avatarURL ?? "https://picsum.photos/seed/\(entity.userId)100/100"
    }
}
