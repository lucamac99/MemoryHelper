import LocalAuthentication
import SwiftUI

enum BiometricType {
    case none
    case touchID
    case faceID
    
    var icon: String {
        switch self {
        case .none: return "person.fill"
        case .touchID: return "touchid"
        case .faceID: return "faceid"
        }
    }
}

class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @Published var biometricType: BiometricType = .none
    @Published var isAuthenticated = false
    
    private let context = LAContext()
    
    init() {
        checkBiometricType()
    }
    
    func checkBiometricType() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID:
                biometricType = .touchID
            case .faceID:
                biometricType = .faceID
            default:
                biometricType = .none
            }
        }
    }
    
    func authenticate() async throws {
        guard biometricType != .none else { return }
        
        let reason = "Unlock Memory Helper"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            await MainActor.run {
                self.isAuthenticated = success
            }
        } catch {
            throw error
        }
    }
} 