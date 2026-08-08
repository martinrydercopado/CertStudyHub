import SwiftUI

struct NeedsReviewView: View {
    @Bindable var viewModel: StudyViewModel
    let certConfig: CertConfig

    var body: some View {
        VStack(spacing: 0) {
            // Back bar
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.goBack()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(certConfig.primaryColor)
                }

                Spacer()

                if !viewModel.needsReviewItems.isEmpty {
                    CopyButton(markdown: CopyHelper.markdownForNeedsReview(
                        items: viewModel.needsReviewItems
                    ))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            if viewModel.needsReviewItems.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    Text("All Clear!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text("No topics marked for review.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.needsReviewItems) { item in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.navigateToTopic(
                                        sectionIndex: item.sectionIndex,
                                        objectiveIndex: item.objectiveIndex,
                                        topicIndex: item.topicIndex
                                    )
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.orange)

                                        Text(item.sectionTitle)
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(item.sectionColor)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }

                                    Text(item.topic.question)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)

                                    Text(item.objectiveTitle)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(PlatformColor.background)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
    }
}
