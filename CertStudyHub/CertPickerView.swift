import SwiftUI

struct CertPickerView: View {
    private let certs = CertCatalog.all
    private let deepDives = CertCatalog.deepDives
    private let certifications = CertCatalog.certifications
    private let progressManager = ProgressManager.shared
    @State private var showBackup = false

    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 400), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // Expiration Warning Banner (iOS only – free provisioning profiles expire; macOS apps do not)
                    #if os(iOS)
                    if progressManager.isExpiringSoon {
                        Button { showBackup = true } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.white)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(progressManager.isExpired
                                         ? "App may have expired"
                                         : progressManager.daysRemaining >= 1
                                           ? "App expires in ~\(progressManager.daysRemaining) day\(progressManager.daysRemaining == 1 ? "" : "s")"
                                           : "App expires in ~\(progressManager.hoursRemaining) hour\(progressManager.hoursRemaining == 1 ? "" : "s")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    Text("Tap to back up your study progress")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.85))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(.plain)
                    }
                    #endif

                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.indigo, .teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Cert Study Hub")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Choose a topic to study")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)

                    // ── Deep Dives Section ──
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Deep Dives")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("In-depth study guides — not official Salesforce certifications")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(deepDives) { cert in
                                NavigationLink(value: cert.id) {
                                    CertCard(cert: cert)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // ── Certifications Section ──
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Certifications")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Official Salesforce certification exam prep")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(certifications) { cert in
                                NavigationLink(value: cert.id) {
                                    CertCard(cert: cert)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // AI Disclaimer
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("Some content in this app was generated by AI and may contain inaccuracies.")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                }
            }
            .background(PlatformColor.groupedBackground)
            .navigationDestination(for: String.self) { certId in
                if let cert = certs.first(where: { $0.id == certId }) {
                    CertHomeView(certConfig: cert)
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button { showBackup = true } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .sheet(isPresented: $showBackup) {
                ProgressExportView()
            }
        }
    }
}

// MARK: - Cert Card

struct CertCard: View {
    let cert: CertConfig

    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [cert.primaryColor, cert.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: cert.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }

            // Title
            Text(cert.name)
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            // Subtitle blurb (deep dives)
            if let subtitle = cert.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }

            // Stats (certifications only)
            if !cert.isBonusTopic {
                HStack(spacing: 16) {
                    if cert.questionCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(cert.primaryColor)
                            Text("\(cert.questionCount) questions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if cert.topicCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "book.fill")
                                .font(.caption)
                                .foregroundStyle(cert.primaryColor)
                            Text("\(cert.topicCount) topics")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Deep dive: Reference Guide badge
            if cert.isBonusTopic {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text.fill")
                        .font(.caption2)
                    Text("Reference Guide")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(cert.primaryColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(cert.primaryColor.opacity(0.1))
                )
            }

            // Passing score badge (certifications only)
            if !cert.isBonusTopic {
                Text("Passing: \(cert.passingScore)%")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(cert.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(cert.primaryColor.opacity(0.1))
                    )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(PlatformColor.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PlatformColor.separator, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
