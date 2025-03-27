import Foundation

struct WordListsManager {
    static let shared = WordListsManager()
    
    // Categories for the word lists with varying difficulty
    let categories: [WordCategory] = [
        WordCategory(
            name: "Basic",
            description: "Common everyday words",
            words: basicWords
        ),
        WordCategory(
            name: "Intermediate", 
            description: "Less common words",
            words: intermediateWords
        ),
        WordCategory(
            name: "Advanced",
            description: "Abstract or specialized words",
            words: advancedWords
        )
    ]
    
    // Gets a random selection of words from a specific category
    func getRandomWords(fromCategory categoryIndex: Int, count: Int) -> [String] {
        guard categoryIndex >= 0 && categoryIndex < categories.count else {
            return []
        }
        
        let category = categories[categoryIndex]
        return Array(category.words.shuffled().prefix(count))
    }
    
    // Gets random words with a specific difficulty level (1-3)
    func getRandomWordsForLevel(level: Int, count: Int) -> [String] {
        let categoryIndex = min(max(level - 1, 0), categories.count - 1)
        return getRandomWords(fromCategory: categoryIndex, count: count)
    }
    
    // Basic words - level 1
    static let basicWords: [String] = [
        // Household items
        "chair", "table", "bed", "lamp", "door", "window", "carpet", "mirror", "clock", "phone",
        "dish", "cup", "spoon", "fork", "knife", "bowl", "plate", "glass", "mug", "pan",
        // Food
        "apple", "banana", "orange", "milk", "bread", "cheese", "meat", "rice", "pasta", "soup",
        "water", "pizza", "egg", "fish", "butter", "salt", "sugar", "fruit", "cake", "ice",
        // Clothing
        "shirt", "pants", "dress", "shoe", "hat", "sock", "coat", "glove", "scarf", "belt",
        // Nature
        "tree", "flower", "grass", "river", "lake", "ocean", "mountain", "sky", "sun", "moon",
        "star", "rain", "snow", "wind", "cloud", "leaf", "rock", "plant", "beach", "forest",
        // Animals
        "dog", "cat", "bird", "fish", "horse", "cow", "sheep", "pig", "mouse", "rabbit",
        // Body parts
        "head", "hand", "foot", "eye", "ear", "nose", "mouth", "hair", "arm", "leg",
        // Colors
        "red", "blue", "green", "yellow", "black", "white", "brown", "pink", "purple", "orange",
        // Transportation
        "car", "bus", "train", "plane", "boat", "bike", "truck", "taxi", "ship", "road"
    ]
    
    // Intermediate words - level 2
    static let intermediateWords: [String] = [
        // Building/Architecture
        "mansion", "castle", "palace", "tower", "cottage", "bungalow", "apartment", "cathedral", "temple", "monument",
        "bridge", "tunnel", "highway", "boulevard", "avenue", "corridor", "balcony", "terrace", "garden", "fountain",
        // Geography
        "island", "peninsula", "desert", "canyon", "valley", "plateau", "volcano", "glacier", "waterfall", "jungle",
        "savanna", "prairie", "lagoon", "harbor", "delta", "estuary", "horizon", "equator", "tropics", "arctic",
        // Professions
        "doctor", "lawyer", "engineer", "teacher", "scientist", "artist", "musician", "writer", "chef", "architect",
        "journalist", "detective", "programmer", "designer", "manager", "director", "professor", "surgeon", "pilot", "astronaut",
        // Sports/Recreation
        "tennis", "soccer", "baseball", "hockey", "basketball", "volleyball", "swimming", "skating", "skiing", "sailing",
        "boxing", "wrestling", "climbing", "dancing", "painting", "singing", "theater", "cinema", "concert", "festival",
        // Materials
        "ceramic", "porcelain", "crystal", "marble", "granite", "bronze", "copper", "silver", "platinum", "titanium",
        "aluminum", "leather", "velvet", "cotton", "linen", "rubber", "plastic", "silicon", "carbon", "diamond",
        // Technology
        "computer", "tablet", "camera", "printer", "scanner", "monitor", "keyboard", "speaker", "microphone", "battery",
        "wireless", "internet", "network", "software", "hardware", "database", "algorithm", "processor", "memory", "storage"
    ]
    
    // Advanced words - level 3
    static let advancedWords: [String] = [
        // Abstract concepts
        "freedom", "justice", "wisdom", "courage", "loyalty", "honesty", "integrity", "empathy", "compassion", "tolerance",
        "harmony", "balance", "essence", "virtue", "eternity", "infinity", "paradox", "symmetry", "entropy", "synergy",
        // Philosophy and thought
        "paradigm", "metaphor", "analogy", "inference", "deduction", "intuition", "cognition", "perception", "conception", "revelation",
        "hypothesis", "theory", "thesis", "antithesis", "synthesis", "dialectic", "empiricism", "rationalism", "pragmatism", "existentialism",
        // Academic/Scientific
        "quantum", "relativity", "thermodynamics", "metabolism", "photosynthesis", "biodiversity", "ecosystem", "atmosphere", "phenomenon", "correlation",
        "causation", "algorithm", "derivative", "coefficient", "polynomial", "logarithm", "frequency", "amplitude", "resonance", "molecule",
        // Economics/Politics
        "democracy", "republic", "monarchy", "oligarchy", "capitalism", "socialism", "communism", "liberalism", "conservatism", "diplomacy",
        "recession", "inflation", "deflation", "monopoly", "subsidy", "tariff", "sanction", "embargo", "sovereignty", "constitution",
        // Psychology
        "consciousness", "subconscious", "motivation", "behavior", "stimulus", "response", "cognition", "emotion", "memory", "perception",
        "personality", "identity", "anxiety", "depression", "therapy", "counseling", "resilience", "neurosis", "psychosis", "catharsis",
        // Literature/Rhetoric
        "metaphor", "simile", "allegory", "personification", "hyperbole", "irony", "paradox", "oxymoron", "euphemism", "allusion",
        "narrative", "discourse", "rhetoric", "exposition", "symbolism", "imagery", "alliteration", "onomatopoeia", "juxtaposition", "denouement"
    ]
}

struct WordCategory {
    let name: String
    let description: String
    let words: [String]
} 