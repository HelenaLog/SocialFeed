import Network

protocol NetworkReachability: AnyObject {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}

final class NetworkMonitor: NetworkReachability {
    
    // MARK: Private Properties
    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor
    private(set) var isConnected: Bool = false
    
    // MARK: Init
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    // MARK: Deinit
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Public Methods

extension NetworkMonitor {
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.isConnected = path.status != .unsatisfied
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
