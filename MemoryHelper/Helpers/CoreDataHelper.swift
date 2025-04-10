import CoreData
import FirebaseAuth

class CoreDataHelper {
    static let shared = CoreDataHelper()
    
    private init() {}
    
    /// Returns a predicate that filters data for the current user
    var userPredicate: NSPredicate? {
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        return NSPredicate(format: "userId == %@", userId)
    }
    
    /// Adds the current user's ID to a new CoreData entity
    func setUserID(for object: NSManagedObject) {
        if let userId = Auth.auth().currentUser?.uid {
            object.setValue(userId, forKey: "userId")
        }
    }
    
    /// Applies user filtering to a fetch request
    func applyUserFilter<T>(to fetchRequest: NSFetchRequest<T>) {
        if let predicate = userPredicate {
            if let existingPredicate = fetchRequest.predicate {
                // Combine with existing predicate using AND
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    existingPredicate,
                    predicate
                ])
            } else {
                fetchRequest.predicate = predicate
            }
        }
    }
} 