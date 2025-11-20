import CoreData

struct Post: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

protocol StorageType {
    func savePosts(_ posts: [Post])
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void)
}

final class StorageService {
    
    // MARK: Private Properties
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FeedPost")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        return container
    }()
    
    // MARK: Init
    
    private init() {}
}

// MARK: - StorageType

extension StorageService: StorageType {
    func savePosts(_ posts: [Post]) {
        persistentContainer.performBackgroundTask { context in
            
            for post in posts {
                let postEntity = PostEntity(context: context)
                postEntity.id = Int64(post.id)
                postEntity.userId = Int64(post.userId)
                postEntity.title = post.title
                postEntity.body = post.body
            }
            
            do {
                try context.save()
            } catch {
                context.rollback()
                print("Failed to save posts: \(error)")
            }
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        persistentContainer.performBackgroundTask { context in
            
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            do {
                let postEntities = try context.fetch(request)
                
                let posts = postEntities.map {
                    Post(
                        userId: Int($0.userId),
                        id: Int($0.id),
                        title: $0.title ?? String(),
                        body: $0.body ?? String()
                    )
                }
                
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
