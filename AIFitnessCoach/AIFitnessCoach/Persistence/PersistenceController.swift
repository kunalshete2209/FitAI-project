import CoreData
import Foundation

final class SavedWorkoutEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var createdAt: Date
    @NSManaged var planData: Data
}

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AIFitnessCoach", managedObjectModel: Self.makeModel())

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save(_ plan: WorkoutPlan) throws {
        let context = container.viewContext
        let request = SavedWorkoutEntity.fetchRequest(for: plan.id)
        let entity = try context.fetch(request).first ?? SavedWorkoutEntity(context: context)
        entity.id = plan.id
        entity.title = plan.title
        entity.createdAt = plan.createdAt
        entity.planData = try JSONEncoder().encode(plan)
        try context.save()
    }

    func fetchPlans() throws -> [WorkoutPlan] {
        let request = SavedWorkoutEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        return try container.viewContext.fetch(request).compactMap { entity in
            try? JSONDecoder().decode(WorkoutPlan.self, from: entity.planData)
        }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "SavedWorkoutEntity"
        entity.managedObjectClassName = NSStringFromClass(SavedWorkoutEntity.self)

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .UUIDAttributeType
        id.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let planData = NSAttributeDescription()
        planData.name = "planData"
        planData.attributeType = .binaryDataAttributeType
        planData.isOptional = false

        entity.properties = [id, title, createdAt, planData]
        model.entities = [entity]
        return model
    }
}

extension SavedWorkoutEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<SavedWorkoutEntity> {
        NSFetchRequest<SavedWorkoutEntity>(entityName: "SavedWorkoutEntity")
    }

    @nonobjc class func fetchRequest(for id: UUID) -> NSFetchRequest<SavedWorkoutEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return request
    }
}
