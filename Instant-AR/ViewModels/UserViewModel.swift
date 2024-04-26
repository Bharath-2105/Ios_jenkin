import Foundation

class UserViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isAuthenticating = true
    
    let apiManager = APIManager()
    var otpToken: String = ""
    var token: Token?
    func getUser(onSuccess: @escaping (User?) -> (), onFailure: @escaping (String) -> ()) {
        guard let url = URL(string: Constants.baseUrl + Endpoints.getUser) else {
            onFailure(Messages.invalidUrl)
            return
        }
        
        apiManager.request(url: url, method: .GET, parameters: nil) { [weak self] (result: Result<User, Error>)  in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        self?.user = user
                        onSuccess(user)
                    }
                case .failure(let error):
                    onFailure(error.localizedDescription)
                }
            }
        }
    }
    
    func sendOtp(email: String,onSuccess: @escaping (String?) -> (), onFailure: @escaping (String) -> ()) {
        guard let url = URL(string: Constants.baseUrl + Endpoints.sendOtp) else { onFailure(Messages.invalidUrl)
            return
        }
        let parameters: [String:Any] = [Constants.email: email]
        apiManager.request(url: url, method: .POST, parameters: parameters, isTokenRefresh: false) { [weak self] (result: Result< OtpResponse, Error>) in
            switch result {
            case .success(let otpResponse):
                self?.otpToken = otpResponse.otpToken
                onSuccess(self?.otpToken)
            case .failure(let error):
                onFailure(error.localizedDescription)
            }
        }
    }
    
    func verifyOtp(otp: String, email: String, onSuccess: @escaping (Token?) -> (), onFailure: @escaping (String) -> ()) {
        guard let url = URL(string: Constants.baseUrl + Endpoints.verifyOtp) else { onFailure(Messages.invalidUrl)
            return
        }
        let parameters = [Constants.otp: otp, Constants.email: email, Constants.otpToken: otpToken] as [String : Any]
        apiManager.request(url: url, method: .POST, parameters: parameters, isTokenRefresh: false) { [weak self] (result: Result<Token, Error>) in
            switch result {
            case .success(let tokenResponse):
                self?.token = tokenResponse
                SharedUserDefaults.shared.set(value: tokenResponse.accessToken, forKey: userDefaultsKey.accessToken.rawValue)
                SharedUserDefaults.shared.set(value: tokenResponse.refreshToken, forKey: userDefaultsKey.refreshToken.rawValue)
                SharedUserDefaults.shared.set(value: true, forKey: userDefaultsKey.isLoggedIn.rawValue)
                onSuccess(tokenResponse)
            case .failure(let error):
                onFailure(error.localizedDescription)
            }
        }
    }
    
   func checkAuthenticationStatus(silent:Bool = false, onSuccess: (() -> Void)? = nil, onFailure: (() -> Void)? = nil) {
       
       if(!silent){
           DispatchQueue.main.async {
               self.isAuthenticating = true
           }
       }
       
       if let _ = SharedUserDefaults.shared.getValue(forKey: userDefaultsKey.accessToken.rawValue){
           self.getUser { user in
               DispatchQueue.main.async {
                   self.isAuthenticated = true
                   self.isAuthenticating = false
                   onSuccess?()
               }
           } onFailure: { error in
               DispatchQueue.main.async {
                   self.isAuthenticated = false
                   self.isAuthenticating = false
                   onFailure?()
               }
           }
       } else {
           DispatchQueue.main.async {
               self.isAuthenticated = false
               self.isAuthenticating = false
               onFailure?()
           }
       }
   }
    
func deleteUser(onSuccess: @escaping (ResultMessage?) -> (), onFailure: @escaping (String) -> ()){
    guard let url = URL(string: Constants.baseUrl + Endpoints.deleteUser) else {
        onFailure(Messages.invalidUrl)
        return
    }
    
    apiManager.request(url: url, method: .DELETE, parameters: nil) { (result: Result< ResultMessage, Error>) in
        switch result {
        case .success(let result):
            DispatchQueue.main.async {
                self.user = nil
                onSuccess(result)
            }
        case .failure(let error):
            onFailure(error.localizedDescription)
        }
    }
}
}
