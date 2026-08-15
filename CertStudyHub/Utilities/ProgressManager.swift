import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Manages study progress export / import and free-provisioning expiration tracking.
@Observable
final class ProgressManager {

    // MARK: – Singleton
    static let shared = ProgressManager()

    // MARK: – Constants
    private static let firstLaunchKey   = "certStudyHub_firstLaunchDate"
    private static let freeProvDays     = 6          // Apple free-account profile lifetime (conservative; profiles nominally say 7 days but expire ~6 days in practice)

    // MARK: – Published State
    private(set) var firstLaunchDate: Date?
    var showExportImportSheet = false
    var showExpirationWarning = false
    var alertMessage: String = ""
    var showAlert: Bool = false

    // MARK: – Init
    private init() {
        loadFirstLaunchDate()
        evaluateExpiration()
    }

    // MARK: – First-Launch Tracking
    private func loadFirstLaunchDate() {
        let buildDate = Self.executableModificationDate() ?? Date()
        if let stored = UserDefaults.standard.object(forKey: Self.firstLaunchKey) as? Date {
            // If the binary is newer than the stored first-launch date, the user
            // re-built and re-installed — reset the countdown from the new build.
            if buildDate > stored {
                UserDefaults.standard.set(buildDate, forKey: Self.firstLaunchKey)
                firstLaunchDate = buildDate
            } else {
                firstLaunchDate = stored
            }
        } else {
            UserDefaults.standard.set(buildDate, forKey: Self.firstLaunchKey)
            firstLaunchDate = buildDate
        }
    }

    /// Returns the modification date of the app's main executable, which updates
    /// every time Xcode re-builds and installs the app. This lets us detect
    /// re-installs that reset the free-provisioning clock.
    private static func executableModificationDate() -> Date? {
        guard let execPath = Bundle.main.executablePath else { return nil }
        return try? FileManager.default.attributesOfItem(atPath: execPath)[.modificationDate] as? Date
    }

    var estimatedExpirationDate: Date? {
        guard let launch = firstLaunchDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: Self.freeProvDays, to: launch)
    }

    var daysRemaining: Int {
        guard let expiry = estimatedExpirationDate else { return Self.freeProvDays }
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
        return max(0, remaining)
    }

    var hoursRemaining: Int {
        guard let expiry = estimatedExpirationDate else { return Self.freeProvDays * 24 }
        let remaining = Calendar.current.dateComponents([.hour], from: Date(), to: expiry).hour ?? 0
        return max(0, remaining)
    }

    var isExpired: Bool      { daysRemaining == 0 && hoursRemaining == 0 }
    var isExpiringSoon: Bool { daysRemaining <= 2 || isExpired }

    private func evaluateExpiration() {
        showExpirationWarning = isExpiringSoon
    }

    // MARK: – Export
    /// Gathers all cert progress from UserDefaults into a single dictionary and returns JSON Data.
    func exportAllProgress() -> Data? {
        var payload: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]

        var certData: [[String: Any]] = []
        for cert in CertCatalog.all {
            let studyKey = "\(cert.storageKeyPrefix)StudyTopicStatuses"
            var entry: [String: Any] = [
                "certId": cert.id,
                "certName": cert.name,
                "storageKeyPrefix": cert.storageKeyPrefix
            ]
            if let raw = UserDefaults.standard.data(forKey: studyKey),
               let dict = try? JSONDecoder().decode([String: TopicStatus].self, from: raw) {
                // Re-encode as simple string dict for portability
                let simplified = dict.mapValues { $0.rawValue }
                entry["studyTopicStatuses"] = simplified
            }
            certData.append(entry)
        }
        payload["certifications"] = certData

        return try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
    }

    /// Returns a shareable file URL in the temp directory.
    func exportToFile() -> URL? {
        guard let data = exportAllProgress() else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: Date())
        let filename = "CertStudyHub_Progress_\(dateStr).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: – Import
    func importProgress(from data: Data) -> Bool {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let certs = json["certifications"] as? [[String: Any]]
        else { return false }

        for certEntry in certs {
            guard let prefix = certEntry["storageKeyPrefix"] as? String,
                  let statuses = certEntry["studyTopicStatuses"] as? [String: String]
            else { continue }

            // Convert back to TopicStatus
            var decoded: [String: TopicStatus] = [:]
            for (topicId, rawValue) in statuses {
                if let status = TopicStatus(rawValue: rawValue) {
                    decoded[topicId] = status
                }
            }

            let studyKey = "\(prefix)StudyTopicStatuses"
            if let encoded = try? JSONEncoder().encode(decoded) {
                UserDefaults.standard.set(encoded, forKey: studyKey)
            }
        }

        return true
    }

    func importProgress(from url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        return importProgress(from: data)
    }
}
