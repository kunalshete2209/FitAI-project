import Foundation

@MainActor
final class WorkoutPlannerViewModel: ObservableObject {
    @Published var profile = FitnessProfile()
    @Published var currentPlan: WorkoutPlan?
    @Published var savedPlans: [WorkoutPlan] = []
    @Published var isGenerating = false
    @Published var isGeneratingDiet = false
    @Published var errorMessage: String?
    @Published var shareItem: ShareItem?

    private let service = OpenAIWorkoutService(useMockResponses: true)
    private let persistence = PersistenceController.shared

    init() {
        loadSavedPlans()
    }

    func generatePlan() {
        guard !isGenerating else { return }
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let plan = try await service.generatePlan(for: profile)
                currentPlan = plan
            } catch {
                errorMessage = error.localizedDescription
            }
            isGenerating = false
        }
    }

    func saveCurrentPlan() {
        guard let currentPlan else { return }
        save(currentPlan)
    }

    func generateDietPlan() {
        guard !isGeneratingDiet else { return }
        isGeneratingDiet = true
        errorMessage = nil

        Task {
            do {
                let dietPlan = try await service.generateDietPlan(for: profile)
                if var plan = currentPlan {
                    plan.dietPlan = dietPlan
                    currentPlan = plan
                    save(plan)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isGeneratingDiet = false
        }
    }

    func loadSavedPlans() {
        do {
            savedPlans = try persistence.fetchPlans()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectSavedPlan(_ plan: WorkoutPlan) {
        currentPlan = plan
        profile = plan.profile
    }

    func toggleCompletion(for day: WorkoutDay) {
        guard var plan = currentPlan else { return }

        if plan.completedDayIDs.contains(day.id) {
            plan.completedDayIDs.remove(day.id)
        } else {
            plan.completedDayIDs.insert(day.id)
        }

        currentPlan = plan
        save(plan)
    }

    func exportCurrentPlan() {
        guard let currentPlan else { return }

        do {
            shareItem = ShareItem(url: try PDFExporter.makePDF(for: currentPlan))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save(_ plan: WorkoutPlan) {
        do {
            try persistence.save(plan)
            loadSavedPlans()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}
