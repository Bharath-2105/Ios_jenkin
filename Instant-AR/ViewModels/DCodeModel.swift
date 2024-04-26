
import Foundation
import Kingfisher

class DCodeModel: ObservableObject{
    
    @Published var discovery: Discovery? = nil
    @Published var savedDiscoveries: [Discovery] = []
    @Published var parseStatusMessage = ""
    @Published var incomingUrlFromAppClip: URL?
    @Published var isCameraAccessDenied = false

    let apiManager = APIManager()
    var saveDiscoveryResult: Result< ResultMessage, Error>? = nil
    var observer: NSObjectProtocol?
    
    func setScannedUrl(url:URL, onSuccess: @escaping () -> (), onFailure: @escaping (String) -> ()){
        // Parse the url and get the code from the query parameter which is id
        let ( id, message) = parseUrl(url: url)
        DispatchQueue.main.async {
            self.parseStatusMessage = message;
        }
        if((id) != nil){
            // Call API using API Manager to get the deails of the Discovrey
            self.getDiscoveryDetails(id: id!) {
                DispatchQueue.main.async {
                    self.parseStatusMessage = ""
                }
                // Save the discovery
                self.saveDiscovery(id:id!)
                self.prefetchDiscoveryData()
                onSuccess()
            } onFailure: { error in
                DispatchQueue.main.async {
                    self.parseStatusMessage = error.description
                }
                onFailure(error.description)
            }
        } else {
            onFailure(parseStatusMessage)
        }
    }
    
    private func parseUrl(url: URL) -> (id: String?, parseStatusMessage: String) {
        
        let components = URLComponents(string: url.absoluteString)
        var id : String? = nil
        var parseStatusMessage = Messages.invalidQRCode
        
        if let host = components?.host, let queryItems = components?.queryItems {
            
            if host == Constants.appClipDomain {
                parseStatusMessage = Messages.dcodeIsMissing
                for item in queryItems {
                    if item.name == Constants.id {
                        if((item.value) != nil && item.value!.count > 0){
                            id = item.value
                            parseStatusMessage = ""
                        }
                        break
                    }
                }
            }
        }
        
        return (id, parseStatusMessage)
    }
    
    func getDiscoveryDetails(id: String, onSuccess: @escaping () -> (), onFailure: @escaping (String) -> ()) {
        guard let url = URL(string: Constants.baseUrl + Endpoints.getDiscoveryDetails + id) else {
            onFailure(Messages.invalidUrl)
            return
        }
        apiManager.request(url: url, method: .GET, parameters: nil) { (result: Result< Discovery, Error>) in
            switch result {
            case .success(let discovery):
                DispatchQueue.main.async {
                    self.discovery = discovery
                    onSuccess()
                }
            case .failure(let error):
                onFailure(error.localizedDescription)
            }
        }
    }
    
    func saveDiscovery(id: String, onSuccess: (() -> ())? = nil, onFailure: ((String) -> ())? = nil) {
        guard let url = URL(string: Constants.baseUrl + Endpoints.discoveryInfo) else {
            onFailure?(Messages.invalidUrl)
            return
        }
        
        let parameters = [Constants.id: id]
        
        apiManager.request(url: url, method: .POST, parameters: parameters) { (result: Result< ResultMessage, Error>) in
            switch result {
            case .success(_):
                self.getSavedDiscoveris()
                onSuccess?()
            case .failure(let error):
                self.saveDiscoveryResult = result
                onFailure?(error.localizedDescription)
            }
            
        } statusCode: { statusCode in
            switch self.saveDiscoveryResult {
            case .success(_):
                print(Constants.success)
            case .failure(let error):
                if statusCode == 403{
                    SharedUserDefaults.shared.set(value: id, forKey: userDefaultsKey.discoveryIdToSave.rawValue)
                }
                onFailure?(error.localizedDescription)
            case .none:
                return
            }
        }
    }
    
    func saveUnSavedDiscovery(){
        if let id = SharedUserDefaults.shared.getValue(forKey: userDefaultsKey.discoveryIdToSave.rawValue) as? String {
            self.saveDiscovery(id: id)
            SharedUserDefaults.shared.removeValue(forKey: userDefaultsKey.discoveryIdToSave.rawValue)
        }
    }
    
    func getSavedDiscoveris(onSuccess: (() -> ())? = nil, onFailure: ((String) -> ())? = nil) {
        guard let url = URL(string: Constants.baseUrl + Endpoints.discoveryInfo) else {
            onFailure?(Messages.invalidUrl)
            return
        }

        apiManager.request(url: url, method: .GET, parameters: nil) { (result: Result< [Discovery], Error>) in
            switch result {
            case .success(let discoveries):
                DispatchQueue.main.async {
                    self.savedDiscoveries.removeAll()
                    self.savedDiscoveries.append(contentsOf: discoveries)
                    onSuccess?()
                }
            case .failure(let error):
                onFailure?(error.localizedDescription)
            }
        }
    }
    
    
    func deleteDiscovery(itemId: [String], onSuccess: @escaping (ResultMessage?) -> (), onFailure: @escaping (String) -> ()){
        guard let url = URL(string: Constants.baseUrl + Endpoints.discoveryInfo) else {
            onFailure(Messages.invalidUrl)
            return
        }
        
        let parameters = [Constants.id: itemId]
        
        apiManager.request(url: url, method: .DELETE, parameters: parameters) { (result: Result< ResultMessage, Error>) in
            switch result {
            case .success(let result):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    for id in itemId {
                        if let index = savedDiscoveries.firstIndex(where: { $0.id == id }) {
                            savedDiscoveries.remove(at: index)
                        }
                    }
                    onSuccess(result)
                }
            case .failure(let error):
                onFailure(error.localizedDescription)
            }
        }
    }
    
    
    private func prefetchDiscoveryData(){
        if let discovery = self.discovery{
            
            switch discovery.type {
            case .image:
                prefetchImage()
                
            case .model:
                prefetchModel()
                
            case .pdf:
                prefetchPDFFile()
                
            default:
                break
            }
        }
    }
    
    private func prefetchImage(){
        
        if let placementImageUrl = discovery?.mediaInfo {
            if(discovery?.type == .image){
                _ = FileCache.shared.getCachedFile(for: placementImageUrl)
            }
        }
        
        if discovery?.arMode == true {
            if let markerImageUrl = discovery?.imageUrl{
                _ = FileCache.shared.getCachedFile(for: markerImageUrl)
            }
        }
    }
    
    private func prefetchModel(){
        if let modelUrl = discovery?.threeDModelUsdz{
            _ = FileCache.shared.getCachedFile(for: modelUrl)
        }
    }
    
    private func prefetchPDFFile(){
        if let pdfUrl = discovery?.pdfUrl{
            _ = FileCache.shared.getCachedFile(for: pdfUrl)
        }
    }
}
