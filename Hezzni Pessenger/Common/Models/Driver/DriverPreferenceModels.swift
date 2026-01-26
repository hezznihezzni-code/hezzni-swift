import Foundation

// MARK: - Driver Preferences

struct DriverPreferencesResponse: Decodable {
    let status: String
    let message: String
    let data: OuterData
    let timestamp: String

    struct OuterData: Decodable {
        let status: String
        let data: InnerData

        struct InnerData: Decodable {
            let preferences: [DriverPreference]
        }
    }
}

struct DriverPreference: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let key: String
    let description: String
    let createdAt: String?
    let updatedAt: String?
    let driverRidePreference: DriverRidePreference?

    struct DriverRidePreference: Decodable, Hashable {
        let isActive: Bool
    }

    /// Convenience flag the UI can use for initial selection.
    var isActive: Bool {
        driverRidePreference?.isActive ?? false
    }
}

// MARK: - Driver Online/Offline

struct DriverGoOnlineResponse: Decodable {
    let status: String
    let message: String
    let data: DataPayload
    let timestamp: String

    struct DataPayload: Decodable {
        let isOnline: Bool
        let activePreferences: [Int]?
    }
}

struct DriverGoOfflineResponse: Decodable {
    let status: String
    let message: String
    let data: DataPayload
    let timestamp: String

    struct DataPayload: Decodable {
        let isOnline: Bool
        let activePreferences: [Int]?
    }
}
