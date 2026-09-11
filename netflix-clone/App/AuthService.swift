//
//  AuthService.swift
//  netflix-clone
//

import FirebaseAuth
import GoogleSignIn
import UIKit

/// Handles Google Sign-In via Firebase Auth. Returns a Firebase ID token
/// that the backend verifies via `POST /v1/auth/signin`.
@MainActor
enum AuthService {

    // MARK: - Google Sign-In

    /// Present Google Sign-In flow. Returns Firebase ID token on success.
    /// Times out after `timeout` seconds; throws `AuthError.timeout`.
    static func signInWithGoogle(timeout: TimeInterval = 120) async throws -> String {
        try await withThrowingTaskGroup(of: String.self) { group in
            // ← tugas utama: Google flow
            group.addTask {
                try await googleSignInFlow()
            }
            // ← timer timeout
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw AuthError.timeout
            }
            // ← hasil pertama menang; sisanya dibatalkan
            guard let token = try await group.next() else {
                throw AuthError.signInFailed("Unknown error")
            }
            group.cancelAll()
            return token
        }
    }

    /// Google Sign-In flow tanpa timeout (single responsibility).
    private static func googleSignInFlow() async throws -> String {
        // ← dapat root VC untuk present Google Sign-In sheet
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }

        // ← jalankan Google Sign-In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.noIDToken
        }

        // ← authenticate ke Firebase Auth dengan Google credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)

        // ← dapat Firebase ID token (dikirim ke backend)
        let firebaseToken = try await authResult.user.getIDToken()
        return firebaseToken
    }

    // MARK: - Sign Out

    static func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }

    // MARK: - Error

    enum AuthError: LocalizedError {
        case timeout
        case noRootViewController
        case noIDToken
        case signInFailed(String)

        var errorDescription: String? {
            switch self {
            case .timeout: return "Sign-in timeout — coba lagi"
            case .noRootViewController: return "Root view controller not found"
            case .noIDToken: return "Failed to get ID token from Google"
            case .signInFailed(let msg): return "Sign-in failed: \(msg)"
            }
        }
    }
}