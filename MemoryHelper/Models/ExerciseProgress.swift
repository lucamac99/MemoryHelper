import Foundation
import CoreData

class ExerciseProgressManager: ObservableObject {
    static let shared = ExerciseProgressManager()
    
    @Published var exerciseStats: [String: ExerciseStat] = [:]
    
    init() {
        loadStats()
    }
    
    func recordExerciseCompletion(exerciseId: String, score: Int, maxScore: Int) {
        var stat = exerciseStats[exerciseId] ?? ExerciseStat()
        
        stat.completedCount += 1
        stat.lastCompletedDate = Date()
        
        let percentage = Double(score) / Double(maxScore) * 100
        stat.averageScore = (stat.averageScore * Double(stat.completedCount - 1) + percentage) / Double(stat.completedCount)
        
        if percentage > stat.highScore {
            stat.highScore = percentage
        }
        
        exerciseStats[exerciseId] = stat
        saveStats()
    }
    
    private func loadStats() {
        do {
            if let data = UserDefaults.standard.data(forKey: "exerciseStats") {
                let decoded = try JSONDecoder().decode([String: ExerciseStat].self, from: data)
                exerciseStats = decoded
                #if DEBUG
                print("Successfully loaded exercise stats")
                #endif
            }
        } catch {
            // If there's a decoding error, reset stats instead of crashing
            exerciseStats = [:]
            #if DEBUG
            print("Error loading exercise stats: \(error.localizedDescription)")
            #endif
            
            // Remove corrupted data
            UserDefaults.standard.removeObject(forKey: "exerciseStats")
        }
    }
    
    private func saveStats() {
        do {
            let encoded = try JSONEncoder().encode(exerciseStats)
            UserDefaults.standard.set(encoded, forKey: "exerciseStats")
        } catch {
            #if DEBUG
            print("Error saving exercise stats: \(error.localizedDescription)")
            #endif
        }
    }
}

struct ExerciseStat: Codable {
    var completedCount: Int = 0
    var lastCompletedDate: Date?
    var highScore: Double = 0.0
    var averageScore: Double = 0.0
} 