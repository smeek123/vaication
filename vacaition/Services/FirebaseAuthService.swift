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
                self.errorMessage = self.userFriendlyErrorMessage(from: error, isSignUp: true)
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
                self.errorMessage = self.userFriendlyErrorMessage(from: error, isSignUp: false)
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
                self.errorMessage = self.userFriendlyErrorMessage(from: error, isSignUp: false)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Firestore Methods
    
    private func loadUserFromFirestore(uid: String) {
        firestore.collection("users").document(uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = self?.userFriendlyErrorMessage(from: error, isSignUp: false) ?? "Unable to load your account. Please try again."
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
                self.errorMessage = self.userFriendlyErrorMessage(from: error, isSignUp: false)
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
    
    func submitFeatureRequest(_ request: String) async throws {
        let featureRequest: [String: Any] = [
            "request": request,
            "createdAt": Timestamp(date: Date())
        ]
        
        try await firestore.collection("featureRequests").addDocument(data: featureRequest)
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
    
    private func userFriendlyErrorMessage(from error: Error, isSignUp: Bool) -> String {
        let nsError = error as NSError
        
        // Check if it's a Firebase Auth error
        if let errorCode = AuthErrorCode(rawValue: nsError.code) {
            return authErrorCodeMessage(errorCode: errorCode, isSignUp: isSignUp)
        }
        
        // Check if it's a Firestore error
        if nsError.domain == "FIRFirestoreErrorDomain" {
            return "Unable to save your information. Please check your connection and try again."
        }
        
        // Generic error message
        if isSignUp {
            return "Unable to create account. Please check your information and try again."
        } else {
            return "Unable to sign in. Please check your email and password and try again."
        }
    }
    
    private func authErrorCodeMessage(errorCode: AuthErrorCode, isSignUp: Bool) -> String {
        
        switch errorCode {
        case .wrongPassword, .userNotFound:
            if isSignUp {
                return "An account with this email already exists. Please sign in instead."
            } else {
                return "The email or password did not match our records. Please try again."
            }
        case .emailAlreadyInUse:
            return "An account with this email already exists. Please sign in instead."
        case .weakPassword:
            return "Password is too weak. Please choose a stronger password with at least 6 characters."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please wait a moment and try again."
        case .userDisabled:
            return "This account has been disabled. Please contact support for assistance."
        case .operationNotAllowed:
            return "This sign-in method is not allowed. Please contact support."
        case .missingEmail:
            return "Please enter your email address."
        case .requiresRecentLogin:
            return "For your security, please sign in again to complete this action."
        case .credentialAlreadyInUse:
            return "This account is already linked to another sign-in method."
        case .invalidCredential:
            return "Invalid credentials. Please check your email and password."
        case .accountExistsWithDifferentCredential:
            return "An account already exists with the same email but different sign-in method."
        case .invalidActionCode:
            return "This link is invalid or has expired. Please request a new one."
        case .expiredActionCode:
            return "This link has expired. Please request a new password reset link."
        case .invalidVerificationCode:
            return "The verification code is invalid. Please try again."
        case .invalidVerificationID:
            return "Verification failed. Please try again."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        default:
            // For any other errors, provide a generic but helpful message
            if isSignUp {
                return "Unable to create account. Please check your information and try again."
            } else {
                return "Unable to sign in. Please check your email and password and try again."
            }
        }
    }
}
