
import SwiftUI
import RealmSwift
import StoreKit
import AVFoundation

@MainActor
final class OnlineViewModel: ObservableObject {
    
    private var userDefaultsManager: UserDefaultsManager = UserDefaultsManager()
    private var firebaseManager: FirebaseManager = FirebaseManager()
    
    @Published var isSignedIn: Bool
    @Published var isLoading: Bool = false
    @Published var packs: [FirebasePack] = []
    @Published var myPacks: [FirebasePack] = []
    @Published var questions: [Card] = []
    @Published var favorites: [Card] = []
    @Published var users: [FirebaseUser] = []
    @Published var selectedSavingType: Pack?
    
    init() {
        self.isSignedIn = firebaseManager.user != nil
    }
    
    private func fetchPacks(_ userId: String? = nil, completion: @escaping () -> Void) {
        packs = []
        firebaseManager.fetchPacks(userId) { [weak self] packs in
            self?.packs = packs
            completion()
        }
    }
    
    private func fetchQuestions(_ userId: String? = nil, for pack: Pack? = nil, completion: @escaping () -> Void) {
        questions = []
        firebaseManager.fetchQuestions(userId, for: pack) { [weak self] questions in
            self?.questions = questions
            completion()
        }
    }
    
    private func fetchUsers(completion: @escaping () -> Void) {
        users = []
        firebaseManager.fetchAllUsers { [weak self] users in
            self?.users = users
            completion()
        }
    }
    
    private func fetchFavorites(completion: @escaping () -> Void) {
        firebaseManager.fetchFavorites { [weak self] favs in
            self?.favorites = favs
            completion()
        }
    }
    
    func fetchAll() {
        isLoading = true
        fetchQuestions { [weak self] in
            self?.fetchPacks {
                self?.fetchUsers {
                    self?.fetchMyPacks {
                        self?.fetchFavorites {
                            self?.isLoading = false
                        }
                    }
                }
            }
        }
    }
    
    private func fetchMyPacks(completion: @escaping () -> Void) {
        packs = []
        firebaseManager.fetchMyPacks { [weak self] packs in
            self?.myPacks = packs
            completion()
        }
    }
    
    func fetchMyContent() {
        isLoading = true
        fetchMyPacks { [weak self] in
            self?.fetchFavorites {
                self?.isLoading = false
            }
        }
    }
    
    func sign(email: String, password: String, completion: @escaping (Bool, Bool) -> Void) {
        isLoading = true
        firebaseManager.signIn(email: email, password: password) { [weak self] successSignIn, isRightPassword in
            guard isRightPassword else {
                completion(false, false)
                return
            }
            if successSignIn {
                self?.isSignedIn = true
                self?.isLoading = false
                completion(true, true)
            } else {
                self?.firebaseManager.signUp(email: email, password: password) { successSignUp in
                    if successSignUp {
                        self?.isSignedIn = true
                        self?.isLoading = false
                        completion(true, true)
                    } else {
                        self?.isLoading = false
                        completion(false, true)
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        firebaseManager.reset(for: email, completion: completion)
    }
    
    func signOut() {
        firebaseManager.signOut()
        isSignedIn = false
    }
    
    func createPack(_ pack: Pack, tags: [String]) {
        firebaseManager.createPack(pack, tags: tags)
    }
    
    func createQuestion(_ question: Card) {
        guard let selectedSavingType else { return }
        firebaseManager.createQuestion(question, for: selectedSavingType)
    }
    
    func getUser() -> FirebaseUser? {
        guard let user = firebaseManager.user else { return nil }
        let id = user.uid
        let email = user.email ?? "Unknown"
        let displayName = user.displayName ?? email
        let photoURL = user.photoURL
        return FirebaseUser(id: id, email: email, displayName: displayName, photoURL: photoURL)
    }
    
    func deletePack(_ pack: Pack) {
        isLoading = true
        firebaseManager.deletePack(pack.id) { [weak self] success in
            self?.isLoading = false
        }
    }
    
    func deleteQuestion(_ question: Card) {
        guard let selectedSavingType else { return }
        isLoading = true
        firebaseManager.deleteQuestion(question.id, for: selectedSavingType) { [weak self] success in
            self?.isLoading = false
        }
    }
    
    func addToFavorites(_ question: Card) {
        firebaseManager.addQuestionToFavorites(question) { [weak self] success in
            if success {
                self?.favorites.append(question)
            }
        }
    }
    
    func removeFromFavorites(_ question: Card) {
        firebaseManager.removeQuestionFromFavorites(question) { [weak self] success in
            if success {
                self?.favorites.removeAll(where: { $0 == question })
            }
        }
    }
    
}
