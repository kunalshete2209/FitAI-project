import Foundation

struct OpenAIWorkoutService {
    var useMockResponses = true
    var model = "gpt-4.1-mini"

    func generatePlan(for profile: FitnessProfile) async throws -> WorkoutPlan {
        if useMockResponses {
            try await Task.sleep(for: .milliseconds(950))
            return Self.mockPlan(for: profile)
        }

        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty else {
            throw WorkoutServiceError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ChatRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: Self.systemPrompt),
                ChatMessage(role: "user", content: Self.userPrompt(for: profile))
            ],
            temperature: 0.65
        ))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw WorkoutServiceError.badResponse
        }

        let chat = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chat.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw WorkoutServiceError.badResponse
        }

        let generated = try JSONDecoder().decode(GeneratedWorkoutPlan.self, from: jsonData)
        return generated.plan(profile: profile)
    }

    func generateDietPlan(for profile: FitnessProfile) async throws -> DietPlan {
        if useMockResponses {
            try await Task.sleep(for: .milliseconds(800))
            return Self.mockDietPlan(for: profile)
        }

        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty else {
            throw WorkoutServiceError.missingAPIKey
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(ChatRequest(
            model: model,
            messages: [
                ChatMessage(role: "system", content: Self.dietSystemPrompt),
                ChatMessage(role: "user", content: Self.userPrompt(for: profile))
            ],
            temperature: 0.55
        ))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw WorkoutServiceError.badResponse
        }

        let chat = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chat.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw WorkoutServiceError.badResponse
        }

        return try JSONDecoder().decode(DietPlan.self, from: jsonData)
    }

    private static let systemPrompt = """
    You are a certified fitness coach. Create safe, practical workout plans. Return only valid JSON matching this schema: {"title":String,"subtitle":String,"coachNotes":[String],"days":[{"day":String,"focus":String,"estimatedMinutes":Int,"warmup":String,"cooldown":String,"exercises":[{"name":String,"sets":String,"reps":String,"rest":String,"instructions":String}]}]}
    """

    private static let dietSystemPrompt = """
    You are a practical nutrition coach. Create a simple diet plan that supports the user's fitness goal. Return only valid JSON matching this schema: {"title":String,"dailyCalories":String,"proteinTarget":String,"hydration":String,"notes":[String],"meals":[{"name":String,"timing":String,"foods":[String],"calories":String,"reason":String}]}
    """

    private static func userPrompt(for profile: FitnessProfile) -> String {
        """
        Age: \(profile.age). Level: \(profile.fitnessLevel.rawValue). Equipment: \(profile.equipment.rawValue). Goal: \(profile.goal.rawValue). Schedule: \(profile.daysPerWeek) days/week, \(profile.minutesPerSession) min/session. Limitations: \(profile.limitations.isEmpty ? "none" : profile.limitations).
        """
    }

    static func mockPlan(for profile: FitnessProfile) -> WorkoutPlan {
        let days = (1...profile.daysPerWeek).map { index in
            WorkoutDay(
                day: "Day \(index)",
                focus: focus(for: profile.goal, index: index),
                estimatedMinutes: profile.minutesPerSession,
                warmup: "5 minutes of light cardio, shoulder circles, hip openers, and bodyweight squats.",
                exercises: mockExercises(for: profile, index: index),
                cooldown: "Walk for 3 minutes, then stretch the main muscles trained today."
            )
        }

        return WorkoutPlan(
            title: "\(profile.goal.rawValue) Plan",
            subtitle: "\(profile.daysPerWeek)x/week with \(profile.equipment.rawValue.lowercased())",
            profile: profile,
            days: days,
            coachNotes: [
                "Keep 1-2 reps in reserve on most working sets.",
                "Increase load or reps slightly when every set feels controlled.",
                "Stop any movement that causes sharp pain and swap it for a comfortable alternative."
            ]
        )
    }

    private static func focus(for goal: FitnessGoal, index: Int) -> String {
        switch goal {
        case .strength: return ["Push Strength", "Lower Body", "Pull Strength", "Full Body"][index % 4]
        case .muscle: return ["Chest and Triceps", "Back and Biceps", "Legs", "Shoulders and Core"][index % 4]
        case .fatLoss: return ["Metabolic Circuit", "Lower Body Burn", "Upper Body Circuit", "Zone 2 Conditioning"][index % 4]
        case .endurance: return ["Tempo Conditioning", "Core Stability", "Intervals", "Recovery Cardio"][index % 4]
        case .mobility: return ["Hips", "Spine", "Shoulders", "Full Body Flow"][index % 4]
        }
    }

    private static func mockExercises(for profile: FitnessProfile, index: Int) -> [Exercise] {
        let equipmentName = profile.equipment.rawValue
        return [
            Exercise(name: index.isMultiple(of: 2) ? "Goblet Squat" : "Incline Push-Up", sets: "3", reps: "8-12", rest: "75 sec", instructions: "Use \(equipmentName.lowercased()) as available. Move with control and keep the final reps challenging."),
            Exercise(name: index.isMultiple(of: 2) ? "Romanian Deadlift" : "One-Arm Row", sets: "3", reps: "10-12", rest: "75 sec", instructions: "Keep a neutral spine and pause briefly at the strongest position."),
            Exercise(name: "Core Finisher", sets: "2", reps: "40 sec", rest: "45 sec", instructions: "Brace your abs, breathe steadily, and keep the movement crisp.")
        ]
    }

    static func mockDietPlan(for profile: FitnessProfile) -> DietPlan {
        DietPlan(
            title: "\(profile.goal.rawValue) Nutrition Plan",
            dailyCalories: calorieTarget(for: profile.goal),
            proteinTarget: "1.6-2.0g protein per kg body weight",
            hydration: "2.5-3.5 liters water daily, plus extra around training",
            meals: [
                Meal(name: "Breakfast", timing: "7:30 AM", foods: ["Greek yogurt", "Banana", "Oats", "Chia seeds"], calories: "450-550", reason: "Slow carbs and protein help energy stay stable through the morning."),
                Meal(name: "Lunch", timing: "1:00 PM", foods: ["Grilled paneer or chicken", "Rice or roti", "Mixed vegetables", "Curd"], calories: "600-700", reason: "Balanced protein, carbs, and fiber support training recovery."),
                Meal(name: "Pre-Workout", timing: "60 min before training", foods: ["Coffee or tea", "Fruit", "Small handful of nuts"], calories: "180-250", reason: "Light fuel without making the session feel heavy."),
                Meal(name: "Dinner", timing: "8:00 PM", foods: ["Dal or lean protein", "Vegetables", "Roti or quinoa", "Salad"], calories: "500-650", reason: "Protein and micronutrients support overnight repair.")
            ],
            notes: [
                "Adjust portions every 2 weeks based on weight, energy, and workout performance.",
                "Keep most meals simple; consistency matters more than perfect macro math.",
                "For medical conditions, allergies, or strict diets, consult a qualified professional."
            ]
        )
    }

    private static func calorieTarget(for goal: FitnessGoal) -> String {
        switch goal {
        case .fatLoss: return "10-15% below maintenance"
        case .muscle, .strength: return "5-10% above maintenance"
        case .endurance: return "maintenance with extra carbs around training"
        case .mobility: return "maintenance with high protein and fiber"
        }
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

private struct ChatMessage: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: ChatMessage
    }
}

private struct GeneratedWorkoutPlan: Decodable {
    let title: String
    let subtitle: String
    let coachNotes: [String]
    let days: [GeneratedWorkoutDay]

    func plan(profile: FitnessProfile) -> WorkoutPlan {
        WorkoutPlan(
            title: title,
            subtitle: subtitle,
            profile: profile,
            days: days.map(\.workoutDay),
            coachNotes: coachNotes
        )
    }
}

private struct GeneratedWorkoutDay: Decodable {
    let day: String
    let focus: String
    let estimatedMinutes: Int
    let warmup: String
    let exercises: [GeneratedExercise]
    let cooldown: String

    var workoutDay: WorkoutDay {
        WorkoutDay(day: day, focus: focus, estimatedMinutes: estimatedMinutes, warmup: warmup, exercises: exercises.map(\.exercise), cooldown: cooldown)
    }
}

private struct GeneratedExercise: Decodable {
    let name: String
    let sets: String
    let reps: String
    let rest: String
    let instructions: String

    var exercise: Exercise {
        Exercise(name: name, sets: sets, reps: reps, rest: rest, instructions: instructions)
    }
}

enum WorkoutServiceError: LocalizedError {
    case missingAPIKey
    case badResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add OPENAI_API_KEY to the Xcode scheme or keep mock mode enabled."
        case .badResponse:
            return "The workout coach response could not be parsed."
        }
    }
}
