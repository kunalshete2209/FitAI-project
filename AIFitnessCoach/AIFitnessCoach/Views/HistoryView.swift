import SwiftUI

struct HistoryView: View {
    let plans: [WorkoutPlan]
    let select: (WorkoutPlan) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Saved Plans")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(plans.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.mint, in: Capsule())
            }

            if plans.isEmpty {
                Text("Generated plans you save will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 8))
            } else {
                ForEach(plans) { plan in
                    Button {
                        select(plan)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(plan.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(plan.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.55))
                            }

                            Spacer()

                            Text("\(Int(plan.completionRatio * 100))%")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.mint)
                        }
                        .padding(14)
                        .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}
