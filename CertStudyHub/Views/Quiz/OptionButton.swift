import SwiftUI

struct OptionButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let hasSubmitted: Bool
    let isCorrectAnswer: Bool
    let isMultiSelect: Bool
    let primaryColor: Color
    let action: () -> Void

    private var backgroundColor: Color {
        if hasSubmitted {
            if isCorrectAnswer {
                return Color.green.opacity(0.12)
            } else if isSelected {
                return Color.red.opacity(0.12)
            }
            return PlatformColor.secondaryBackground
        }
        return isSelected ? primaryColor.opacity(0.08) : PlatformColor.secondaryBackground
    }

    private var borderColor: Color {
        if hasSubmitted {
            if isCorrectAnswer {
                return .green
            } else if isSelected {
                return .red
            }
            return PlatformColor.separator
        }
        return isSelected ? primaryColor : PlatformColor.separator
    }

    // Leading indicator icon
    private var leadingIcon: String {
        if isMultiSelect {
            return isSelected ? "checkmark.square.fill" : "square"
        } else {
            return isSelected ? "largecircle.fill.circle" : "circle"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Selection indicator
                Image(systemName: hasSubmitted ? (isCorrectAnswer ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : leadingIcon)) : leadingIcon)
                    .font(.title3)
                    .foregroundStyle(
                        hasSubmitted
                            ? (isCorrectAnswer ? .green : (isSelected ? .red : .secondary))
                            : (isSelected ? primaryColor : .secondary)
                    )
                    .frame(width: 24)

                // Option letter badge
                Text(letter)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(isSelected && !hasSubmitted ? .white : .secondary)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isSelected && !hasSubmitted ? primaryColor : PlatformColor.tertiaryBackground)
                    )

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

                Spacer(minLength: 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: isSelected || (hasSubmitted && isCorrectAnswer) ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(hasSubmitted)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.3), value: hasSubmitted)
    }
}
