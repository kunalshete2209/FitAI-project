# AI Fitness Coach

A SwiftUI + OpenAI portfolio project built for a 2-3 week LinkedIn timeline. The app generates personalized workout plans, saves them locally, tracks completed sessions, and exports plans as PDFs.

## Features

- SwiftUI profile form: age, level, equipment, goals, days/week, session length, limitations.
- OpenAI Chat Completions integration through `URLSession`.
- Mock mode for reliable demo videos without an API key.
- MVVM architecture with a focused `WorkoutPlannerViewModel`.
- Programmatic Core Data persistence for saved workout plans.
- Completion tracking per workout day.
- Regenerate Workout button for quickly creating a fresh plan from the same profile.
- AI Diet Plan generation with meals, calories, protein target, hydration, and nutrition notes.
- PDF export and iOS share sheet.
- Animated premium UI designed for a short LinkedIn demo.

## Run

1. Open `AIFitnessCoach.xcodeproj` in Xcode.
2. Choose an iPhone simulator.
3. Run the app. It works immediately in mock mode.

## Enable OpenAI

In `WorkoutPlannerViewModel.swift`, change:

```swift
private let service = OpenAIWorkoutService(useMockResponses: true)
```

to:

```swift
private let service = OpenAIWorkoutService(useMockResponses: false)
```

Then add `OPENAI_API_KEY` to the app scheme environment variables.

## LinkedIn caption

Built an AI Fitness Coach in SwiftUI.

The app takes a user's age, fitness level, available equipment, goal, and weekly schedule, then generates a personalized day-by-day workout plan with sets, reps, rest periods, coaching notes, local saving, completion tracking, AI diet plan generation, workout regeneration, and PDF export.

Tech used: SwiftUI, MVVM, URLSession, OpenAI Chat Completions, Core Data, PDF export, Codable, async/await.
