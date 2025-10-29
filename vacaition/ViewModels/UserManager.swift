import SwiftUI
import Combine

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let firebaseAuthService: FirebaseAuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: FirebaseAuthService = FirebaseAuthService()) {
        self.firebaseAuthService = authService
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        firebaseAuthService.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        firebaseAuthService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }
    
    func updateUser(_ user: User) {
        Task {
            await firebaseAuthService.updateUser(user)
        }
    }
    
    func addTrip(_ trip: Trip) {
        Task {
            await firebaseAuthService.addTrip(trip)
        }
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) {
        Task {
            await firebaseAuthService.updateUserPreferences(preferences)
        }
    }
    
    func signOut() {
        Task {
            await firebaseAuthService.signOut()
        }
    }
    
    // MARK: - Auth Service Access
    var authService: FirebaseAuthService {
        return firebaseAuthService
    }
    
    var isAuthenticated: Bool {
        return firebaseAuthService.isAuthenticated
    }
    
    var errorMessage: String? {
        return firebaseAuthService.errorMessage
    }
    
    func clearError() {
        firebaseAuthService.clearError()
    }
}
