import Foundation
import SwiftUI
import Combine

extension Notification.Name {
    static let downloadComplete = Notification.Name(AppNotifications.fileCacheDownloadComplete)
    static let downloadProgress = Notification.Name(AppNotifications.fileCacheDownloadProgress)
}
class FileCache : NSObject, URLSessionDownloadDelegate{
   
    static let shared = FileCache()
    private var downloadQueue: [URL] = []
    private var currentDownloadTask: URLSessionDownloadTask?
    private var cacheDirectory: URL
    private var fileAccessInfo: [URL: Date] = [:] // Stores last access date for each file
    
    private var downloadMetaDataPath: URL
    private var downloadMetaData: [URL: [String: Any]] = [:]
    
    private var resumeDataMetaDataPath: URL


       private var currentDownloadURL: URL?
    
    private lazy var urlSession: URLSession = {
          URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }()
    
    private override init() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentDirectory.appendingPathComponent(Constants.fileCache, isDirectory: true)
        downloadMetaDataPath = cacheDirectory.appendingPathComponent(Constants.downloadMetaDataJson)
        resumeDataMetaDataPath = cacheDirectory.appendingPathComponent(Constants.resumeDataMetaDataJson)
    }
    
    func setupFileCache(){
        
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        if fileManager.fileExists(atPath: downloadMetaDataPath.path) {
            if let data = try? Data(contentsOf: downloadMetaDataPath),
               let metadata = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                metadata.forEach { key, value in
                    var correctedValue = value
                    if let dateString = value[Constants.lastAccessed] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = Constants.dateFormat
                        correctedValue[Constants.lastAccessed] = dateFormatter.date(from: dateString)
                    }
                    if let url = URL(string: key) {
                        downloadMetaData[url] = correctedValue
                    }
                }
            }
        }
        cleanUp()
        resumePendingDownloads()
    }
    
    private func resumePendingDownloads() {
        // Assuming metadata contains info to identify pending downloads
        let pendingDownloads = downloadMetaData.filter { $0.value[Constants.isDownloading] as? Bool ?? false }
        pendingDownloads.keys.forEach { url in
            if currentDownloadTask == nil {
                startOrQueueDownload(for: url)
            } else {
                downloadQueue.append(url) // Add to queue if a download is already in progress
            }
        }
    }
    
    func startOrQueueDownload(for url: URL) {
        if let currentDownloadURL = currentDownloadURL, currentDownloadURL != url {
            // Cancel the current task and capture resume data before starting the new download
            currentDownloadTask?.cancel(byProducingResumeData: { [weak self] resumeData in
                guard let self = self else { return }

                if let resumeData = resumeData {
                    saveResumeData(data: resumeData, forUrl: currentDownloadURL)
                }

                // Ensure this code runs on the main thread if you're updating any UI components or expect it to run on the main thread.
//                DispatchQueue.main.async {
                    self.currentDownloadTask = nil
                    if !self.downloadQueue.contains(currentDownloadURL) {
                        self.downloadQueue.insert(currentDownloadURL, at: 0) // Re-enqueue the canceled download
                    }
                    // Now that the current download is canceled and handled, start the new download
                    self.startDownload(for: url)
//                }
            })
        } else if self.currentDownloadURL == nil {
            // No current download, so start the new download directly
            self.startDownload(for: url)
        }
        // If the requested URL is already downloading, do nothing
    }

    func startDownload(for url: URL) {
        self.currentDownloadURL = url
        var task: URLSessionDownloadTask?

        if let resumeData = getResumeData(forUrl: url) {
            task = urlSession.downloadTask(withResumeData: resumeData)
        } else {
            task = urlSession.downloadTask(with: url)
        }

        self.currentDownloadTask = task
        task?.resume()

        // Update metadata to indicate the download has started
        var metadata = self.downloadMetaData[url] ?? [:]
        metadata[Constants.isDownloading] = true
        self.downloadMetaData[url] = metadata
        self.saveMetadata()
    }

        
        private func processNextInQueue() {
            if !downloadQueue.isEmpty {
                let nextURL = downloadQueue.removeFirst()
                startOrQueueDownload(for: nextURL)
            }
        }
    
    private func updateMetadata(for url: URL, with attributes: [String: Any]) {
          var metadata = downloadMetaData[url] ?? [:]
          attributes.forEach { key, value in
              metadata[key] = value
          }
          downloadMetaData[url] = metadata
          saveMetadata()
      }
    
    private func saveMetadata() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        
        let formattedMetadata: [String: [String: Any]] = downloadMetaData.reduce(into: [:]) { result, entry in
            var entryValue = entry.value
            entryValue.forEach { key, value in
                if let dateValue = value as? Date {
                    // Convert Date to String for JSON serialization
                    entryValue[key] = dateFormatter.string(from: dateValue)
                }
            }
            result[entry.key.absoluteString] = entryValue
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: formattedMetadata)
            try data.write(to: downloadMetaDataPath)
        } catch {
            print(Messages.metadataSavingError + "\(error)")
        }
    }

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            guard let url = downloadTask.originalRequest?.url else { return }
            
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: [Constants.url: url.absoluteString, Constants.progress: Int(progress * 100.0)])
        }
        }
    
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            guard let url = downloadTask.originalRequest?.url else { return }
            
            let localFileName = UUID().uuidString + "_" + (downloadTask.response?.suggestedFilename ?? url.lastPathComponent)
            let destinationURL = cacheDirectory.appendingPathComponent(localFileName)
            try? FileManager.default.moveItem(at: location, to: destinationURL)

            updateMetadata(for: url, with: [Constants.localFileName: localFileName, Constants.lastAccessed: Date(), Constants.isDownloading: false])
            
            
            currentDownloadTask = nil
            currentDownloadURL = nil
            
            deleteResumeData(forUrl: url)
            DispatchQueue.main.async {
                let filePath = self.cacheDirectory.appendingPathComponent(localFileName).absoluteString
                NotificationCenter.default.post(name: .downloadComplete, object: nil, userInfo: [Constants.url: url.absoluteString, Constants.localFilePath: filePath])
            }
            processNextInQueue()
            
        }
    

    
    func getCachedFile(for url: String) -> URL? {
        
        if let url = URL(string: url){
            updateLastAccessTime(for: url)
            
            if let metadata = downloadMetaData[url], let localFileName = metadata[Constants.localFileName] as? String {
                let filePath = cacheDirectory.appendingPathComponent(localFileName)
                if FileManager.default.fileExists(atPath: filePath.path) {
                    return filePath
                } else {
                    startOrQueueDownload(for: url)
                }
            }
            
            if let _ = downloadMetaData[url] {
                // The file is currently downloading but not completed, so we return nil to avoid re-downloading
                return nil
            } else {
                // Start a new download if the file is not in cache or currently downloading
                startOrQueueDownload(for: url)
            }
        }
         
         return nil
     }
     
     private func updateLastAccessTime(for url: URL) {
         if var metadata = downloadMetaData[url] {
             metadata[Constants.lastAccessed] = Date()
             downloadMetaData[url] = metadata
             saveMetadata()
         }
     }
    
    private func saveResumeData(data:Data, forUrl:URL){
        
        let resumeDataString = data.base64EncodedString()
        
        var resumeData: [URL: String] = getReumeDataFromFile()

        resumeData[forUrl] = resumeDataString
        
       saveResumeDataToFile(resumeData:resumeData)
        
    }
    
    private func getReumeDataFromFile()->[URL:String]{
        
        var resumeData: [URL: String] = [:]
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: resumeDataMetaDataPath.path) {
            
                if let data = try? Data(contentsOf: resumeDataMetaDataPath){
                    do {
                        // Attempt to deserialize the JSON data to [String: String]
                        if let stringKeyedDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                            // Convert [String: String] to [URL: String]
                            resumeData = stringKeyedDictionary.reduce(into: [URL: String]()) { result, entry in
                                if let url = URL(string: entry.key) {
                                    result[url] = entry.value
                                }
                            }
                        }
                    } catch {
                        print(Messages.jsonDataDeserializeError + "\(error.localizedDescription)")
                    }
                }
            
        }
        return resumeData
    }
    
    private func saveResumeDataToFile(resumeData : [URL:String]) {
        
        let stringKeyedDictionary = resumeData.reduce(into: [String: String]()) { (result, entry) in
            result[entry.key.absoluteString] = entry.value
        }
        
        // Serialize the dictionary to JSON Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: stringKeyedDictionary, options: .prettyPrinted) else {
            print(Messages.jsonDictSerializeError)
            return
        }
        
        do {
            try jsonData.write(to: resumeDataMetaDataPath, options: .atomic)
            print(Messages.resumeDataSaved + "\(resumeDataMetaDataPath)")
        } catch {
            print(Messages.jsonDataWriteFailure + "\(error.localizedDescription)")
        }
    }
    
    private func getResumeData(forUrl:URL) -> Data? {
        
        let resumeData: [URL: String] = getReumeDataFromFile()
        
        if let resumeDataString = resumeData[forUrl]{
            return Data(base64Encoded: resumeDataString)
        }
        
        return nil
    }
    
    private func deleteResumeData(forUrl:URL) {
        
        var resumeData: [URL: String] = getReumeDataFromFile()
        resumeData.removeValue(forKey: forUrl)
        saveResumeDataToFile(resumeData: resumeData)
    }
    
    private func cleanUp(minutes: Int = 7200) { // Default to 5 days in minutes
        let fileManager = FileManager.default
        let currentTime = Date()
        let expirationInterval = TimeInterval(minutes * 60) // Convert minutes to seconds

        for (url, metadata) in downloadMetaData {
            if let lastAccessed = metadata[Constants.lastAccessed] as? Date {
                // Check if the last accessed time + expirationInterval is before the current time
                if lastAccessed.addingTimeInterval(expirationInterval) < currentTime {
                    // The file was last accessed more than 'minutes' ago, delete it
                    if let localFileName = metadata[Constants.localFileName] as? String {
                        let filePath = cacheDirectory.appendingPathComponent(localFileName)
                        do {
                            try fileManager.removeItem(at: filePath)
                            print(Messages.cacheFileDeletion + "\(filePath.lastPathComponent)")
                        } catch {
                            print(Messages.fileDeletionFailure + "\(error)")
                        }
                        
                        // Remove metadata for the deleted file
                        downloadMetaData.removeValue(forKey: url)
                        // Also, remove any associated resume data
                        deleteResumeData(forUrl: url)
                    }
                }
            }
        }

        // Save the updated metadata
        saveMetadata()
    }



}




struct DownloadNotificationModifier: ViewModifier {
    var onCompletion: (String, String) -> Void
    var onProgress: (String, Int) -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .downloadComplete)) { notification in
                if let userInfo = notification.userInfo,
                   let urlString = userInfo[Constants.url] as? String,
                   let localFilePath = userInfo[Constants.localFilePath] as? String {
                    
                        self.onCompletion(urlString, localFilePath)
                    
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .downloadProgress)) { notification in

                
                if let userInfo = notification.userInfo,
                   let urlString = userInfo[Constants.url] as? String,
                   let progress = userInfo[Constants.progress] as? Int {
                   
                        self.onProgress(urlString, progress)
                    
                }
            }
    }
}

extension View {
    func onDownloadNotification(completion: @escaping (String, String) -> Void, progress: @escaping (String, Int) -> Void) -> some View {
        self.modifier(DownloadNotificationModifier(onCompletion: completion, onProgress: progress))
    }
}
