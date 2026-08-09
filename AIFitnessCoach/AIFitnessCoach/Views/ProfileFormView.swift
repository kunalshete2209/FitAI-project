import SwiftUI

struct ProfileFormView: View {
    @Binding var profile: FitnessProfile
    let isGenerating: Bool
    let generate: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            section("Profile") {
                Stepper("Age \(profile.age)", value: $profile.age, in: 13...80)
                Picker("Level", selection: $profile.fitnessLevel) {
                    ForEach(FitnessLevel.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("Goal", selection: $profile.goal) {
                    ForEach(FitnessGoal.allCases) { Text($0.rawValue).tag($0) }
                }
            }

            section("Training Setup") {
                Picker("Equipment", selection: $profile.equipment) {
                    ForEach(Equipment.allCases) { Text($0.rawValue).tag($0) }
                }
                Stepper("\(profile.daysPerWeek) days per week", value: $profile.daysPerWeek, in: 2...6)
                Stepper("\(profile.minutesPerSession) min sessions", value: $profile.minutesPerSession, in: 20...90, step: 5)
                TextField("Limitations or injuries", text: $profile.limitations, axis: .vertical)
                    .lineLimit(2...4)
            }

            Button(action: generate) {
                HStack {
                    if isGenerating {
                        ProgressView().tint(.black)
                    } else {
                        Image(systemName: "figure.strengthtraining.traditional")
                    }

                    Text(isGenerating ? "Creating Plan" : "Generate Workout Plan")
                        .fontWeight(.bold)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
            }
            .disabled(isGenerating)
        }
        .tint(.mint)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.56))
                .textCase(.uppercase)

            VStack(spacing: 12) {
                content()
            }
            .font(.subheadline)
            .foregroundStyle(.white)
        }
        .padding(16)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.13), lineWidth: 1)
        }
    }
}
