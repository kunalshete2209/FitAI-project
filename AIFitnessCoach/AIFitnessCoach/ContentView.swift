import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutPlannerViewModel()

    var body: some View {
        ZStack {
            AnimatedCoachBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    ProfileFormView(
                        profile: $viewModel.profile,
                        isGenerating: viewModel.isGenerating,
                        generate: viewModel.generatePlan
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.red.opacity(0.28), in: RoundedRectangle(cornerRadius: 8))
                    }

                    if viewModel.isGenerating {
                        LoadingCoachView()
                    }

                    if let plan = viewModel.currentPlan {
                        WorkoutPlanView(
                            plan: plan,
                            isGeneratingDiet: viewModel.isGeneratingDiet,
                            save: viewModel.saveCurrentPlan,
                            export: viewModel.exportCurrentPlan,
                            regenerate: viewModel.generatePlan,
                            generateDiet: viewModel.generateDietPlan,
                            toggleDay: viewModel.toggleCompletion
                        )
                    }

                    HistoryView(plans: viewModel.savedPlans, select: viewModel.selectSavedPlan)
                }
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 36)
            }
        }
        .sheet(item: $viewModel.shareItem) { item in
            ShareSheet(items: [item.url])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Smart Workout Planner", systemImage: "figure.run.circle.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
//                Text("MVVM")
//                    .font(.caption.weight(.bold))
//                    .foregroundStyle(.black)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 7)
//                    .background(.white, in: Capsule())
            }

            Text("Personalized workouts in seconds.")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text("Generate safe day-by-day plans, save them locally, track completion, and export a polished PDF.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct LoadingCoachView: View {
    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Coach is building your plan", systemImage: "sparkles")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(pulse ? 0.22 : 0.08))
                    .frame(height: CGFloat(46 + index * 10))
                    .animation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true).delay(Double(index) * 0.15), value: pulse)
            }
        }
        .padding(16)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .onAppear { pulse = true }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
