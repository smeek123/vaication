import SwiftUI

struct AuthView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var isSignUpMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showPasswordReset = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Header Section
                    headerSection
                    
                    // Auth Form Section
                    authFormSection
                    
                    // Toggle Sign Up/Sign In
                    toggleSection
                    
                    // Password Reset
                    if !isSignUpMode {
                        passwordResetSection
                    }
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.xl)
            }
            .background(
                LiquidGlassBackground()
                    .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .alert("Password Reset", isPresented: $showPasswordReset) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send Reset Email") {
                    Task {
                        await userManager.authService.resetPassword(email: email)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your email address to receive a password reset link.")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // App Icon/Logo
            Image("Ava")
                .resizable()
                .clipShape(Circle())
                .scaledToFit()
                .frame(width: 100, height: 100)
                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                .accessibilityLabel("Ava's avatar")
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Welcome to Vaication")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text(isSignUpMode ? "Create your account to start planning amazing trips" : "Sign in to continue your travel journey")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(isSignUpMode ? "Create account to start planning trips" : "Sign in to continue travel journey")
            }
        }
    }
    
    private var authFormSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Name field (only for sign up)
            if isSignUpMode {
                CustomTextField(
                    text: $name,
                    placeholder: "Full Name",
                    icon: "person.fill",
                    isSecure: false
                )
            }
            
            // Email field
            CustomTextField(
                text: $email,
                placeholder: "Email Address",
                icon: "envelope.fill",
                isSecure: false,
                keyboardType: .emailAddress
            )
            
            // Password field
            CustomTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock.fill",
                isSecure: true
            )
            
            // Confirm Password field (only for sign up)
            if isSignUpMode {
                CustomTextField(
                    text: $confirmPassword,
                    placeholder: "Confirm Password",
                    icon: "lock.fill",
                    isSecure: true
                )
            }
            
            // Error message
            if let errorMessage = userManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(AppTheme.Colors.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.md)
            }
            
            // Submit button
            Button(action: handleSubmit) {
                HStack {
                    if userManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: isSignUpMode ? "person.badge.plus" : "arrow.right")
                            .font(.title2)
                    }
                    
                    Text(isSignUpMode ? "Create Account" : "Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            AppTheme.Colors.primary,
                            AppTheme.Colors.secondary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(AppTheme.CornerRadius.lg)
                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(userManager.isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .accessibilityLabel(isSignUpMode ? "Create account" : "Sign in")
        }
    }
    
    private var toggleSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Divider()
                .background(AppTheme.Colors.primary.opacity(0.3))
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSignUpMode.toggle()
                    userManager.clearError()
                }
            }) {
                HStack {
                    Text(isSignUpMode ? "Already have an account?" : "Don't have an account?")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(isSignUpMode ? "Sign In" : "Sign Up")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .accessibilityLabel(isSignUpMode ? "Switch to sign in" : "Switch to sign up")
        }
    }
    
    private var passwordResetSection: some View {
        Button("Forgot Password?") {
            showPasswordReset = true
        }
        .font(.body)
        .foregroundColor(AppTheme.Colors.primary)
        .accessibilityLabel("Reset password")
        .accessibilityHint("Opens password reset dialog")
    }
    
    // MARK: - Helper Methods
    
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !name.isEmpty && 
                   !confirmPassword.isEmpty &&
                   password == confirmPassword &&
                   isValidEmail(email)
        } else {
            return !email.isEmpty && !password.isEmpty && isValidEmail(email)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func handleSubmit() {
        userManager.clearError()
        
        if isSignUpMode {
            Task {
                await userManager.authService.signUp(email: email, password: password, name: name)
            }
        } else {
            Task {
                await userManager.authService.signIn(email: email, password: password)
            }
        }
    }
}

// MARK: - Custom Text Field Component

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let isSecure: Bool
    var keyboardType: UIKeyboardType = .default
    
    @State private var isSecureVisible = false
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            
            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
                    .font(.body)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .font(.body)
                    .textFieldStyle(PlainTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            if isSecure {
                Button(action: {
                    isSecureVisible.toggle()
                }) {
                    Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.Colors.primary)
                        .accessibilityLabel(isSecureVisible ? "Hide password" : "Show password")
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .liquidGlassCard(cornerRadius: AppTheme.CornerRadius.md, borderTint: AppTheme.Colors.primary)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AuthView()
}
