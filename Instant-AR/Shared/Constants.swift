import Foundation
import SwiftUI

struct AppNotifications {
    static var stopCaptureSession: String = "stopCaptureSession"
    static let receivedForbidden: String = "receivedForbidden"
    static let fileCacheDownloadComplete: String = "FileCacheDownloadComplete"
    static let fileCacheDownloadProgress: String = "FileCacheDownloadProgress"
}

struct Messages {

    static let invalidQRCode: String = "Oops! This QR is on a different adventure.\nTry a D Code QR instead."
    static var dcodeIsMissing: String = "Looks like this code forgot its mission. Let's find a proper D Code!"
    static var fetchingDCodeDetailsMessage : String = "Unraveling the secrets of this D Code...\n Just a moment!"
    static var fetching3DModel : String = "Fetching your 3D experience...\nPlease hold on!"
    static var downloadingPDFFile : String = "Preparing your document... Almost there!"
    static var moveYourPhoneAroundText: String = "Move your phone around \nto locate a flat surface"
    static var tapOnScreenText: String = "Tap on the screen to place \nyour 3D object here"
    static var lookingForImageText: String = "Looking for the image..."
    static var saveDisovery: String = "Save Discoveries"
    static var loginToSave: String = "Log in to D Code App to save your discoveries."
    static var installAppToSave: String = "Install D Code App from the App Store to save your discoveries."
    static var profileCaption: String = "D Code bridges your digital and physical worlds.\nScan, discover, and immerse."
    static var enableCameraForImmersiveText: String = "Unlock the full AR magic! Enable camera access in Settings for immersive exploration."
    static var enableCameraToScanText: String = "Ready to scan? Enable camera access in Settings to dive into the action."
    static var navigateToSettingsText: String =  "Navigate to\nSettings > App Clips > D Code > Camera \nto modify camera permissions."
    static let errorInDeletion: String =  "Error in deletion"
    static let deletionConfirmationText: String =  "Are you sure you want to delete?"
    static let selectAtleastOneItem: String =  "Select atleast one item to delete!"
    static let noDiscoveriesFound: String =  "There is no discovies found to select."
    static let noDiscoveriesYet: String = "No Discoveries Yet.\nScan a D Code QR code to start exploring!"
    static let networkLostTitle: String = "Something Broke!"
    static let networkLostMessage: String = "No internet, please check your connection and try again later"
    static let autoFocusConfigureError: String = "Error configuring auto-focus: "
    static let initCoderError: String = "init(coder:) has not been implemented"
    static let initError: String = "init() has not been implemented"
    static let metalFailureError: String = "Metal is not supported on this device or failed to create shader library."
    static let customMaterialCreationError: String = "Failed to create custom material: "
    static let wrongOtp: String = "Wrong OTP"
    static let loading: String = "Loading..."
    static let invalidUrl: String = "invalid url"
    static let noUserAvailable: String = "no user available"
    static let logoutConfirmation: String = "Are you sure you want to logout?"
    static let accountDeletionConfirmation: String = "Are you sure you want to delete your account?"
    static let enterYourEmail: String = "Enter your email"
    static let enterOtp: String = "Enter the 4 digit OTP sent to your email"
    static let appClipLaunchMessage: String = "App Clip launched with URL: "
    static let jsonDeserializeFailure: String = "Failed to deserialize JSON:"
    static let metadataSavingError: String = "Error saving metadata: "
    static let jsonDataDeserializeError: String = "Failed to deserialize JSON data: "
    static let jsonDictSerializeError: String = "Failed to serialize dictionary to JSON"
    static let resumeDataSaved: String = "Resume data saved to "
    static let jsonDataWriteFailure: String = "Failed to write JSON data to file: "
    static let fileDeletionFailure: String = "Error deleting file: "
    static let cacheFileDeletion: String = "Deleted cached file: "
    static let pointYourCamera: String = "Point your camera at D Code QR code to unlock magical experiences"
    static let modelLoadingFailed: String = "Couldn't load content... Try again later."
    static let modelLoadingInProgress: String = "Preparing your experience... Please wait."
}

struct Images {
    static let discoveriesImage: String = "discoveriesImage"
    static let closeButton: String = "closeButton"
    static let deleteButton: String = "deleteButton"
    static let selectionButton: String = "selectionButton"
    static let qrcodeViewfinder: String = "qrcode.viewfinder"
    static let photoOnRectangle: String = "photo.on.rectangle"
    static let person: String = "person"
    static let networkLostLogo: String = "networkLostLogo"
    static let chevronLeft: String = "chevron.left.circle.fill"
    static let mute: String = "speaker.circle.fill"
    static let unmute: String = "speaker.slash.circle.fill"
    static let defaultVideoIcon: String = "defaultVideoIcon"
    static let defaultImageIcon: String = "defaultImageIcon"
    static let default3DIcon: String = "default3DIcon"
    static let defaultPdfIcon: String = "defaultPdfIcon"
    static let defaultWebLinkIcon: String = "defaultWebLinkIcon"
    static let photo: String = "photo"
    static let loginBackgroundImage: String = "loginBackgroundImage"
    static let launchScreen: String = "launchScreen"
    static let infoIcon: String = "info.circle.fill"
    static let warningIcon: String = "exclamationmark.triangle.fill"
    static let checkmarkIcon: String = "checkmark.circle.fill"
    static let errorIcon: String = "xmark.circle.fill"
    static let xmark: String = "xmark"
    static let logoutButton: String = "logoutButton"
    static let appImage: String = "appImage"
    static let TALogo: String = "TALogo"
    static let appIcon: String = "appIcon"
    static let chevronRight: String = "chevron.right"
    static let qrScanIcon: String = "qrScanIcon"
}

enum userDefaultsKey: String {
    case accessToken  = "accessToken"
    case refreshToken = "refreshToken"
    case isLoggedIn = "isLoggedIn"
    case discoveryIdToSave = "discoveryIdToSave"
}

struct Colors {
    static let adaptiveColor: Color = .primary
}

struct Constants {
    static let mainAppURLScheme: String = "dcodeapp://"
    static let appClipDomain = "dcode-app.web.app"
    static let bundleIdLookupUrl = "https://itunes.apple.com/lookup?bundleId="
    static let mainAppBundleId = "com.teamta.dcode"
    static let baseUrl = "https://dcode.teamta.net/api"
    static let suiteName = "group.teamta.dcodeapp"
    static let delete: String = "Delete"
    static let discoveries: String = "Discoveries"
    static let scan: String = "Scan"
    static let profile: String = "Profile"
    static let keypath: String = "currentItem.presentationSize"
    static let basicShader: String = "basicShader"
    static let basicModifier: String = "basicModifier"
    static let error: String = "ERROR"
    static let url: String = "url"
    static let localFilePath: String = "localFilePath"
    static let email: String = "email"
    static let otpToken: String = "otpToken"
    static let otp: String = "otp"
    static let id: String = "id"
    static let success: String = "Success"
    static let classic: String = "Classic"
    static let ar: String = "AR"
    static let logout: String = "Logout"
    static let deleteAccount: String = "Delete Account"
    static let poweredBy: String = "Powered by"
    static let dcode: String = "D Code"
    static let unknown: String = "Unknown"
    static let CFBundleShortVersionString: String = "CFBundleShortVersionString"
    static let login: String = "LOGIN"
    static let continueText: String = "Continue"
    static let verification: String = "Verification"
    static let base64: String = "base64,"
    static let monitor: String = "Monitor"
    static let settings: String = "Settings"
    static let clip: String = "Clip"
    static let refreshToken: String = "refreshToken"
    static let json: String = "application/json"
    static let contentType: String = "Content-Type"
    static let authorization: String = "Authorization"
    static let bearer: String = "Bearer "
    static let method: String = "Method"
    static let results: String = "results"
    static let trackViewUrl: String = "trackViewUrl"
    static let fileCache: String = "fileCache"
    static let downloadMetaDataJson: String = "downloadMetaData.json"
    static let resumeDataMetaDataJson: String = "resumeDataMetaData.json"
    static let lastAccessed: String = "lastAccessed"
    static let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"
    static let isDownloading: String = "isDownloading"
    static let localFileName: String = "localFileName"
    static let progress: String = "progress"
}

struct Endpoints {
    static let getUser: String = "/user/profile"
    static let sendOtp: String = "/user/send-otp"
    static let verifyOtp: String = "/user/verify-otp"
    static let deleteUser: String = "/appuser/"
    static let getDiscoveryDetails: String = "/dcode/meta?id="
    static let discoveryInfo: String = "/appuser/info"
    static let getRefreshToken: String = "/user/refresh-token"
}

struct Fonts {
    static let interBlack: String = "Inter-Black"
    static let interBold: String = "Inter-Bold"
    static let interRegular: String = "Inter-Regular"
    static let interSemiBold: String = "Inter-SemiBold"
}
