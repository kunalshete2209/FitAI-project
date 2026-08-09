import Foundation

enum FitnessLevel: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }
}

enum FitnessGoal: String, CaseIterable, Identifiable, Codable {
    case strength = "Build Strength"
    case muscle = "Gain Muscle"
    case fatLoss = "Fat Loss"
    case endurance = "Improve Endurance"
    case mobility = "Mobility"

    var id: String { rawValue }
}

enum Equipment: String, CaseIterable, Identifiable, Codable {
    case bodyweight = "Bodyweight"
    case dumbbells = "Dumbbells"
    case bands = "Resistance Bands"
    case fullGym = "Full Gym"

    var id: String { rawValue }
}

struct FitnessProfile: Codable, Equatable {
    var age: Int = 28
    var fitnessLevel: FitnessLevel = .beginner
    var equipment: Equipment = .bodyweight
    var goal: FitnessGoal = .strength
    var daysPerWeek: Int = 4
    var minutesPerSession: Int = 45
    var limitations: String = ""
}

struct WorkoutPlan: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var subtitle: String
    var createdAt = Date()
    var profile: FitnessProfile
    var days: [WorkoutDay]
    var coachNotes: [String]
    var completedDayIDs: Set<UUID> = []
    var dietPlan: DietPlan? = nil

    var completionRatio: Double {
        guard !days.isEmpty else { return 0 }
        return Double(completedDayIDs.count) / Double(days.count)
    }
}

struct WorkoutDay: Identifiable, Codable, Equatable {
    var id = UUID()
    var day: String
    var focus: String
    var estimatedMinutes: Int
    var warmup: String
    var exercises: [Exercise]
    var cooldown: String
}

struct Exercise: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var sets: String
    var reps: String
    var rest: String
    var instructions: String
}

struct DietPlan: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var dailyCalories: String
    var proteinTarget: String
    var hydration: String
    var meals: [Meal]
    var notes: [String]
}

struct Meal: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var timing: String
    var foods: [String]
    var calories: String
    var reason: String
}

struct SavedWorkoutSummary: Identifiable, Equatable {
    let id: UUID
    let title: String
    let createdAt: Date
    let completionRatio: Double
}
