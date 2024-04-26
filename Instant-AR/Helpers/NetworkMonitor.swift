import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: Constants.monitor)
    @Published var isConnected: Bool?
    var networkMonitorCallBack: ((Bool?)->())?

    init() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                self.networkMonitorCallBack?(self.isConnected)
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
