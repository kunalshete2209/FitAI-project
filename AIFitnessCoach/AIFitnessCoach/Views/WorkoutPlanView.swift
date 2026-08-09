import SwiftUI

struct WorkoutPlanView: View {
    let plan: WorkoutPlan
    let isGeneratingDiet: Bool
    let save: () -> Void
    let export: () -> Void
    let regenerate: () -> Void
    let generateDiet: () -> Void
    let toggleDay: (WorkoutDay) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text(plan.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                ProgressRing(progress: plan.completionRatio)
                    .frame(width: 56, height: 56)
            }

            HStack(spacing: 10) {
                Button(action: save) {
                    Label("Save", systemImage: "tray.and.arrow.down")
                }
                Button(action: export) {
                    Label("PDF", systemImage: "square.and.arrow.up")
                }
                Button(action: regenerate) {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(ActionPillButtonStyle())

            Button(action: generateDiet) {
                HStack {
                    if isGeneratingDiet {
                        ProgressView().tint(.black)
                    } else {
                        Image(systemName: "fork.knife.circle.fill")
                    }

                    Text(isGeneratingDiet ? "Creating Diet Plan" : "Generate AI Diet Plan")
                        .fontWeight(.bold)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.mint, in: RoundedRectangle(cornerRadius: 8))
            }
            .disabled(isGeneratingDiet)

            if let dietPlan = plan.dietPlan {
                DietPlanView(dietPlan: dietPlan)
            }

            ForEach(plan.coachNotes, id: \.self) { note in
                Label(note, systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.76))
            }

            ForEach(plan.days) { day in
                DayCard(day: day, isComplete: plan.completedDayIDs.contains(day.id)) {
                    toggleDay(day)
                }
            }
        }
    }
}

private struct DayCard: View {
    let day: WorkoutDay
    let isComplete: Bool
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.day)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.mint)
                    Text(day.focus)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Button(action: toggle) {
                    Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(isComplete ? .mint : .white.opacity(0.55))
                }
                .accessibilityLabel(isComplete ? "Mark incomplete" : "Mark complete")
            }

            Label("\(day.estimatedMinutes) minutes", systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.62))

            Text(day.warmup)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))

            ForEach(day.exercises) { exercise in
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("\(exercise.sets) sets x \(exercise.reps) - rest \(exercise.rest)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.mint)
                    Text(exercise.instructions)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.66))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
            }

            Text(day.cooldown)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))
        }
        .padding(16)
        .background(.white.opacity(isComplete ? 0.16 : 0.1), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isComplete ? .mint.opacity(0.65) : .white.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct ProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.12), lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.mint, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: progress)
    }
}

private struct ActionPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.bold))
            .foregroundStyle(.black)
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(.white.opacity(configuration.isPressed ? 0.72 : 0.96), in: Capsule())
    }
}
