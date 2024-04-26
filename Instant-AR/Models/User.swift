import Foundation

struct User: Codable {
   let id: String
   let name: String?
   var email: String
   let phoneNumber: String?
}
