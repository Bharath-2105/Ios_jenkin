import Foundation

class Discovery: Codable, ObservableObject {
    let id: String
    let imageUrl: String
    let type: DiscoveryType?
    let mediaInfo: String
    let name: String
    let threeDModelUsdz: String
    let threeDModelGltf: String
    let markerImagebase64: String
    let pdfUrl: String
    let arMode: Bool
    let webLink: String
    let logoImage: String

    // Define coding keys to match JSON keys
    private enum CodingKeys: String, CodingKey {
        case id, imageUrl, type, mediaInfo, name, threeDModelUsdz, threeDModelGltf, markerImagebase64, pdfUrl, arMode, webLink, logoImage
    }

    // Custom initializer from Decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        type = try container.decodeIfPresent(DiscoveryType.self, forKey: .type) ?? .unknown
        mediaInfo = try container.decodeIfPresent(String.self, forKey: .mediaInfo) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        threeDModelUsdz = try container.decodeIfPresent(String.self, forKey: .threeDModelUsdz) ?? ""
        threeDModelGltf = try container.decodeIfPresent(String.self, forKey: .threeDModelGltf) ?? ""
        markerImagebase64 = try container.decodeIfPresent(String.self, forKey: .markerImagebase64) ?? ""
        pdfUrl = try container.decodeIfPresent(String.self, forKey: .pdfUrl) ?? ""
        arMode = try container.decodeIfPresent(Bool.self, forKey: .arMode) ?? false
        webLink = try container.decodeIfPresent(String.self, forKey: .webLink) ?? ""
        logoImage = try container.decodeIfPresent(String.self, forKey: .logoImage) ?? ""
    }

    // Implement encode(to encoder: Encoder)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode each property
        try container.encode(id, forKey: .id)
        try container.encode(imageUrl, forKey: .imageUrl)
        // Encode optional properties only if they are not nil
        try container.encodeIfPresent(type, forKey: .type)
        try container.encode(mediaInfo, forKey: .mediaInfo)
        try container.encode(name, forKey: .name)
        try container.encode(threeDModelUsdz, forKey: .threeDModelUsdz)
        try container.encode(threeDModelGltf, forKey: .threeDModelGltf)
        try container.encode(markerImagebase64, forKey: .markerImagebase64)
        try container.encode(pdfUrl, forKey: .pdfUrl)
        try container.encode(arMode, forKey: .arMode)
        try container.encode(webLink, forKey: .webLink)
        try container.encode(logoImage, forKey: .logoImage)
    }
}




enum DiscoveryType: Int,Codable {
    case unknown = 0
    case video   = 1
    case image   = 2
    case text    = 3
    case model   = 4
    case pdf     = 5
    case web     = 6
}


