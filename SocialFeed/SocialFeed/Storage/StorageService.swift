import CoreData

protocol StorageType {
    func savePosts(_ posts: [DisplayPost])
    func fetchPosts(completion: @escaping (Result<[DisplayPost], Error>) -> Void)
    func saveImageData(_ imageData: Data, for postId: Int)
    func toggleLike(for postId: Int64)
    func getImageData(for postId: Int, completion: @escaping (Result<Data?, Error>) -> Void)
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
    
     init() {}
}

// MARK: - StorageType

extension StorageService: StorageType {
    
    func savePosts(_ posts: [DisplayPost]) {
        
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            guard let entity = NSEntityDescription.entity(
                forEntityName: "PostEntity",
                in: context
            ) else {
                return
            }
            for post in posts {
                let postEntity = PostEntity(entity: entity, insertInto: context)
                
                postEntity.id = Int64(post.id)
                postEntity.userId = Int64(post.userId)
                postEntity.title = post.title
                postEntity.body = post.body
                postEntity.isLiked = post.isLiked
                postEntity.avatarURL = post.avatarURL
            }
            
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[DisplayPost], Error>) -> Void) {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.fetchLimit = 1
        
        persistentContainer.performBackgroundTask { context in
            do {
                let postEntities = try context.fetch(request)
                let displayPosts = postEntities.map { DisplayPost(from: $0) }
            
                DispatchQueue.main.async {
                    completion(.success(displayPosts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func toggleLike(for postId: Int64) {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", postId)
        
        persistentContainer.performBackgroundTask { context in
            do {
                let posts = try context.fetch(request)
                if let post = posts.first {
                    post.isLiked.toggle()
                    try context.save()
                }
            } catch {
                context.rollback()
            }
        }
    }
    
    func saveImageData(_ imageData: Data, for postId: Int) {
        persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", postId)
            request.fetchLimit = 1
            
            do {
                if let postEntity = try context.fetch(request).first {
                    postEntity.avatarImageData = imageData
                    try context.save()
                }
            } catch {
                context.rollback()
            }
        }
    }
    
    func getImageData(for postId: Int, completion: @escaping (Result<Data?, Error>) -> Void) {
        persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", postId)
            request.fetchLimit = 1
            
            do {
                guard let postEntity = try context.fetch(request).first else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(postEntity.avatarImageData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
