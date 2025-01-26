
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
    @Published var questions: [Card] = []
    @Published var favorites: [Card] = []
    @Published var users: [FirebaseUser] = []
    @Published var selectedSavingType: CardType?
    
    init() {
        self.isSignedIn = firebaseManager.user != nil
    }
    
    func fetchPacks(_ userId: String? = nil) {
        packs = []
        isLoading = true
        firebaseManager.fetchPacks(userId) { [weak self] packs in
            self?.packs = packs
            self?.firebaseManager.fetchFavorites { favs in
                self?.favorites = favs
                self?.isLoading = false
            }
        }
    }
    
    func fetchQuestions(_ userId: String? = nil, for cardType: CardType? = nil) {
        questions = []
        isLoading = true
        firebaseManager.fetchQuestions(userId, for: cardType) { [weak self] questions in
            self?.questions = questions
            self?.firebaseManager.fetchFavorites { favs in
                self?.favorites = favs
                self?.isLoading = false
            }
        }
    }
    
    func fetchUsers() {
        users = []
        isLoading = true
        firebaseManager.fetchAllUsers { [weak self] users in
            self?.users = users
            self?.firebaseManager.fetchFavorites { favs in
                self?.favorites = favs
                self?.isLoading = false
            }
        }
    }
    
    func sign(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        firebaseManager.signIn(email: email, password: password) { [weak self] successSignIn in
            if successSignIn {
                self?.isLoading = false
                completion(true)
            } else {
                self?.firebaseManager.signUp(email: email, password: password) { successSignUp in
                    if successSignUp {
                        self?.isLoading = false
                        completion(true)
                    } else {
                        self?.isLoading = false
                        completion(false)
                    }
                }
            }
        }
    }
    
    func signOut() {
        firebaseManager.signOut()
    }
    
    func createPack(_ cardType: CardType, tags: [String]) {
        firebaseManager.createPack(cardType, tags: tags)
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
    
    func deletePack(_ cardType: CardType) {
        isLoading = true
        firebaseManager.deletePack(cardType.id) { [weak self] success in
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
