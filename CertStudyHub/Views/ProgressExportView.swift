import SwiftUI

struct ProgressExportView: View {
    @Environment(\.dismiss) private var dismiss
    let progressManager = ProgressManager.shared

    @State private var importerPresented = false
    @State private var exportShareItem: URL?
    @State private var showShareSheet = false
    @State private var statusMessage: String?
    @State private var statusIsError: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.indigo, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Progress Backup")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Export your study progress so you can restore it after reinstalling the app.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 16)

                // Expiration Info
                if let expiry = progressManager.estimatedExpirationDate {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: progressManager.isExpiringSoon
                                  ? "exclamationmark.triangle.fill"
                                  : "clock.fill")
                                .foregroundStyle(progressManager.isExpiringSoon ? .red : .orange)

                            Text(progressManager.isExpiringSoon
                                 ? "App expires soon!"
                                 : "Estimated expiration")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Text(expiry, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(progressManager.daysRemaining) day\(progressManager.daysRemaining == 1 ? "" : "s") remaining")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(progressManager.isExpiringSoon
                                  ? Color.red.opacity(0.08)
                                  : Color.orange.opacity(0.08))
                    )
                    .padding(.horizontal)
                }

                // Summary
                progressSummary

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        exportProgress()
                    } label: {
                        Label("Export Progress", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.indigo, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        importerPresented = true
                    } label: {
                        Label("Import Progress", systemImage: "square.and.arrow.down")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PlatformColor.secondaryBackground)
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(PlatformColor.separator, lineWidth: 0.5)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)

                // Status message
                if let msg = statusMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(statusIsError ? .red : .green)
                        .padding(.bottom, 8)
                }
            }
            .navigationTitle("Backup")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $importerPresented,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            #if os(iOS)
            .sheet(isPresented: $showShareSheet) {
                if let url = exportShareItem {
                    ShareSheet(activityItems: [url])
                }
            }
            #endif
        }
    }

    // MARK: – Summary
    @ViewBuilder
    private var progressSummary: some View {
        VStack(spacing: 12) {
            Text("Current Progress")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                ForEach(CertCatalog.all) { cert in
                    let studyKey = "\(cert.storageKeyPrefix)StudyTopicStatuses"
                    let count = topicCount(for: studyKey)
                    VStack(spacing: 4) {
                        Image(systemName: cert.icon)
                            .font(.title3)
                            .foregroundStyle(cert.primaryColor)
                        Text(cert.shortName)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("\(count) tracked")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PlatformColor.secondaryBackground)
        )
        .padding(.horizontal)
    }

    private func topicCount(for key: String) -> Int {
        guard let data = UserDefaults.standard.data(forKey: key),
              let dict = try? JSONDecoder().decode([String: TopicStatus].self, from: data)
        else { return 0 }
        return dict.filter { $0.value != .notStarted }.count
    }

    // MARK: – Export
    private func exportProgress() {
        guard let url = progressManager.exportToFile() else {
            statusMessage = "Export failed."
            statusIsError = true
            return
        }

        #if os(iOS)
        exportShareItem = url
        showShareSheet = true
        statusMessage = "Progress exported!"
        statusIsError = false
        #else
        // macOS: use NSSavePanel
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = url.lastPathComponent
        panel.begin { response in
            if response == .OK, let dest = panel.url {
                try? FileManager.default.copyItem(at: url, to: dest)
                statusMessage = "Saved to \(dest.lastPathComponent)"
                statusIsError = false
            }
        }
        #endif
    }

    // MARK: – Import
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }

            if progressManager.importProgress(from: url) {
                statusMessage = "Progress restored! Restart the app to see changes."
                statusIsError = false
            } else {
                statusMessage = "Invalid backup file."
                statusIsError = true
            }
        case .failure:
            statusMessage = "Could not open file."
            statusIsError = true
        }
    }
}

// MARK: – iOS Share Sheet
#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiVC: UIActivityViewController, context: Context) {}
}
#endif
