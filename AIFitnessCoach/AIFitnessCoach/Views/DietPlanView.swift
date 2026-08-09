import SwiftUI

struct DietPlanView: View {
    let dietPlan: DietPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Diet Plan")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.mint)
                    Text(dietPlan.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "leaf.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.mint)
            }

            HStack(spacing: 10) {
                nutritionMetric("Calories", dietPlan.dailyCalories)
                nutritionMetric("Protein", dietPlan.proteinTarget)
            }

            Label(dietPlan.hydration, systemImage: "drop.fill")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))

            ForEach(dietPlan.meals) { meal in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(meal.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(meal.timing)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.mint)
                    }

                    Text(meal.foods.joined(separator: " + "))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.74))

                    Text("\(meal.calories) cal - \(meal.reason)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.56))
                }
                .padding(12)
                .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
            }

            ForEach(dietPlan.notes, id: \.self) { note in
                Label(note, systemImage: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.68))
            }
        }
        .padding(16)
        .background(.mint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.mint.opacity(0.3), lineWidth: 1)
        }
    }

    private func nutritionMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.52))
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}
