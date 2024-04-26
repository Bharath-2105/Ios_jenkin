
import Foundation
import UIKit

enum APIError: Error {
    case badURL
    case noRefreshToken
    case unknown
    case tokenRefreshFailed
    case invalidCredentials
}

struct ErrorModel: Codable {
    let error: String
}

enum HttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

class TokenManager {
    static let shared = TokenManager()
    private init() {}
        
    func accessToken() -> String? {
        SharedUserDefaults.shared.getValue(forKey: userDefaultsKey.accessToken.rawValue) as? String
    }
    
    func refreshToken() -> String? {
        SharedUserDefaults.shared.getValue(forKey: userDefaultsKey.refreshToken.rawValue) as? String
    }
    
    func updateTokens(accessToken: String, refreshToken: String) {
        SharedUserDefaults.shared.set(value: accessToken, forKey: userDefaultsKey.accessToken.rawValue)
        SharedUserDefaults.shared.set(value: refreshToken, forKey: userDefaultsKey.refreshToken.rawValue)
    }
    
    func refreshAccessToken(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let refreshToken = self.refreshToken(), let refreshTokenUrl = URL(string: Constants.baseUrl + Endpoints.getRefreshToken) else {
            completion(.failure(APIError.noRefreshToken))
            return
        }
        
        let parameters = [Constants.refreshToken: refreshToken]
        APIManager().request(url: refreshTokenUrl, method: .POST, parameters: parameters) { (result: Result<Token, Error>) in
            switch result {
            case .success(let tokenResponse):
                self.updateTokens(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken)
                completion(.success(()))
            case .failure:
                completion(.failure(APIError.tokenRefreshFailed))
            }
        }
    }
}

class APIManager {
    
    func request<T: Codable>(url: URL, method: HttpMethod, parameters: [String: Any]?, isTokenRefresh: Bool = true, completion: @escaping (Result<T, Error>) -> Void, statusCode: ((Int) -> Void)? = nil) {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(Constants.json, forHTTPHeaderField: Constants.contentType)
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        if let accessToken = TokenManager.shared.accessToken() {
            request.setValue(Constants.bearer + "\(accessToken)", forHTTPHeaderField: Constants.authorization)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                self.handleResponse(httpResponse, with: data, isTokenRefresh: isTokenRefresh, error: error, completion: completion, statusCode: statusCode)
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(APIError.unknown))
            }
        }.resume()
    }
    
    private func handleResponse<T: Codable>(_ response: HTTPURLResponse, with data: Data?, isTokenRefresh: Bool, error: Error?, completion: @escaping (Result<T, Error>) -> Void, statusCode: ((Int) -> Void)? = nil) {
        switch response.statusCode {
        case 200...299:
            guard let data = data else {
                completion(.failure(APIError.unknown))
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error ))
            }
            
        case 401:
            if(isTokenRefresh){
                TokenManager.shared.refreshAccessToken { [weak self] result in
                    switch result {
                    case .success:
                        self?.request(url: response.url!, method: HttpMethod(rawValue: response.allHeaderFields[Constants.method] as? String ?? HttpMethod.GET.rawValue)!, parameters: nil, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                let error = self.parseError(data: data, statusCode: response.statusCode)
                completion(.failure(error ?? APIError.invalidCredentials))
            }
            
        case 403:
//            NotificationCenter.default.post(name: .receivedForbidden, object: nil)
            completion(.failure(error ?? APIError.unknown))
            if let statusCode = statusCode {
                statusCode(403)
            }
        default:
            let error = self.parseError(data: data, statusCode: response.statusCode)
            completion(.failure(error ?? APIError.unknown))
        }
    }
    
    private func parseError(data: Data?, statusCode: Int) -> Error? {
        guard let data = data else { return nil }
        do {
            let errorResponse = try JSONDecoder().decode(ErrorModel.self, from: data)
            return NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.error])
        } catch {
            return error
        }
    }
}
