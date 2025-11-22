import CoreData

protocol StorageType {
    func savePosts(_ posts: [PostViewItem])
    func fetchPosts(page: Int, limit: Int, completion: @escaping (Result<[PostViewItem], StorageError>) -> Void)
    func toggleLike(for postId: Int)
    func saveImageData(_ imageData: Data, for urlString: String)
    func getImageData(for urlString: String, completion: @escaping (Result<Data?, StorageError>) -> Void)
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
    
    func savePosts(_ posts: [PostViewItem]) {
        
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
    
    func fetchPosts(page: Int, limit: Int, completion: @escaping (Result<[PostViewItem], StorageError>) -> Void) {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.fetchLimit = limit
        request.fetchOffset = (page - 1) * limit
        persistentContainer.performBackgroundTask { context in
            do {
                let postEntities = try context.fetch(request)
                let displayPosts = postEntities.map { PostViewItem(from: $0) }
            
                DispatchQueue.main.async {
                    completion(.success(displayPosts))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.fetchFailed))
                }
            }
        }
    }
    
    func toggleLike(for postId: Int) {
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
    
    func saveImageData(_ imageData: Data, for urlString: String) {
        persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "avatarURL == %@", urlString)
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
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

    func getImageData(for urlString: String, completion: @escaping (Result<Data?, StorageError>) -> Void) {
        persistentContainer.performBackgroundTask { context in
            let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "avatarURL == %@", urlString)
            
            do {
                guard let postEntity = try context.fetch(request).first else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                    return
                }
                
                guard let imageData = postEntity.avatarImageData else {
                    DispatchQueue.main.async {
                        completion(.failure(.imageDataNotFound))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(imageData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.fetchFailed))
                }
            }
        }
    }
}
