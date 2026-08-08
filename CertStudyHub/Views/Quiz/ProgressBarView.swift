import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    let currentQuestion: Int
    let totalQuestions: Int
    let score: Int
    let answered: Int
    let primaryColor: Color

    var body: some View {
        VStack(spacing: 8) {
            // Stats row
            HStack {
                Text("Question \(currentQuestion) of \(totalQuestions)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                        Text("\(score)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }

                    if answered > score {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                            Text("\(answered - score)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(primaryColor.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(primaryColor)
                        .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}
