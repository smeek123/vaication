import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class FirebaseAuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen to authentication state changes
        authStateListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.isAuthenticated = true
                    self?.loadUserFromFirestore(uid: user.uid)
                } else {
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, name: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = result.user
            
            // Create user document in Firestore
            let newUser = User(
                id: UUID(uuidString: user.uid) ?? UUID(),
                name: name,
                email: email,
                profileImageURL: nil,
                preferences: UserPreferences()
            )
            
            try await saveUserToFirestore(newUser, uid: user.uid)
            
            DispatchQueue.main.async {
                self.currentUser = newUser
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
            // User will be loaded via the auth state listener
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signOut() async {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func resetPassword(email: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Firestore Methods
    
    private func loadUserFromFirestore(uid: String) {
        firestore.collection("users").document(uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data(),
                      let user = try? Firestore.Decoder().decode(User.self, from: data) else {
                    // If user document doesn't exist, create a default one
                    self?.createDefaultUserDocument(uid: uid)
                    return
                }
                
                self?.currentUser = user
                self?.isLoading = false
            }
        }
    }
    
    private func createDefaultUserDocument(uid: String) {
        guard let firebaseUser = auth.currentUser else { return }
        
        let newUser = User(
            id: UUID(uuidString: uid) ?? UUID(),
            name: firebaseUser.displayName ?? "Traveler",
            email: firebaseUser.email ?? "",
            profileImageURL: nil,
            preferences: UserPreferences()
        )
        
        Task {
            try await saveUserToFirestore(newUser, uid: uid)
        }
    }
    
    private func saveUserToFirestore(_ user: User, uid: String) async throws {
        let data = try Firestore.Encoder().encode(user)
        try await firestore.collection("users").document(uid).setData(data)
    }
    
    func updateUser(_ user: User) async {
        guard let uid = auth.currentUser?.uid else { return }
        
        do {
            try await saveUserToFirestore(user, uid: uid)
            DispatchQueue.main.async {
                self.currentUser = user
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func addTrip(_ trip: Trip) async {
        guard var user = currentUser else { return }
        user.savedTrips.append(trip)
        await updateUser(user)
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) async {
        guard var user = currentUser else { return }
        user.preferences = preferences
        await updateUser(user)
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
}
