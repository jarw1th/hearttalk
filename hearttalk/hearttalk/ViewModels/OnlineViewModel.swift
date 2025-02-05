
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
    @Published var needToUpdate: Bool = false
    @Published var packs: [FirebasePack] = []
    @Published var allPacks: [FirebasePack] = []
    @Published var myPacks: [FirebasePack] = []
    @Published var questions: [Card] = []
    @Published var favorites: FirebasePack
    @Published var users: [FirebaseUser] = []
    @Published var selectedSavingType: Pack?
    var myUser: FirebaseUser? {
        get {
            guard let user = firebaseManager.user else { return nil }
            let id = user.uid
            let email = user.email ?? "Unknown"
            let displayName = user.displayName ?? email
            let photoURL = user.photoURL
            return FirebaseUser(id: id, email: email, displayName: displayName, photoURL: photoURL, lastSeen: Date())
        }
    }
    
    @Published var cards: [Card] = []
    @Published var selectedCards: [Card] = []
    @Published var cardIndex: Int = 0
    
    private(set) var userId: String?
    
    init() {
        self.isSignedIn = firebaseManager.user != nil
        self.userId = firebaseManager.user?.uid
        self.favorites = FirebasePack(pack: Pack(id: UUID().uuidString, name: Localization.onlineFavorites, text: ""), tags: [], user: "", cards: 0)
        self.favorites.pack.color = "D44A13"
    }
    
    func fetchPacks(_ userId: String? = nil, completion: (() -> Void)? = nil) {
        firebaseManager.fetchPacks(userId) { [weak self] packs in
            let packs = packs.filter({
                if userId == nil {
                    self?.allPacks.map({ $0.pack.id }).contains($0.pack.id) != true
                } else {
                    self?.packs.map({ $0.pack.id }).contains($0.pack.id) != true
                }
            })
            guard !packs.isEmpty else {
                completion?()
                return
            }
            if userId == nil {
                self?.allPacks.append(contentsOf: packs)
            } else {
                self?.packs.append(contentsOf: packs)
            }
            completion?()
        }
    }
    
    func fetchQuestions(_ userId: String? = nil, for pack: Pack? = nil, completion: (() -> Void)? = nil) {
        firebaseManager.fetchQuestions(userId, for: pack) { [weak self] questions in
            let questions = questions.filter({
                self?.questions.map({ $0.id }).contains($0.id) != true
            })
            guard !questions.isEmpty else {
                completion?()
                return
            }
            self?.questions.append(contentsOf: questions)
            completion?()
        }
    }
    
    func fetchUsers(completion: (() -> Void)? = nil) {
        firebaseManager.fetchAllUsers { [weak self] users in
            guard self?.users != users else {
                completion?()
                return
            }
            self?.users.append(contentsOf: users)
            completion?()
        }
    }
    
    func fetchFavorites(for user: FirebaseUser? = nil, completion: (() -> Void)? = nil) {
        firebaseManager.fetchFavorites(user?.id) { [weak self] favs in
            self?.favorites = favs
            completion?()
        }
    }
    
    func fetchFavorites(_ userId: String, completion: (() -> Void)? = nil) {
        firebaseManager.fetchFavorites(userId) { [weak self] favs in
            self?.cards = Array(favs.pack.cards)
            completion?()
        }
    }
    
    func fetchAll() {
        myPacks = []
        packs = []
        allPacks = []
        questions = []
        users = []
        firebaseManager.clear()
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
    
    func fetchAll(for user: FirebaseUser) {
        packs = []
        firebaseManager.clear()
        isLoading = true
        fetchFavorites(for: user) { [weak self] in
            self?.fetchPacks(user.id) {
                self?.isLoading = false
            }
        }
    }
    
    func fetchMyPacks(completion: (() -> Void)? = nil) {
        firebaseManager.fetchMyPacks { [weak self] packs in
            self?.myPacks = packs
            completion?()
        }
    }
    
    func fetchMyContent(completion: (() -> Void)? = nil) {
        isLoading = true
        fetchMyPacks { [weak self] in
            self?.fetchFavorites {
                self?.isLoading = false
                completion?()
            }
        }
    }
    
    func fetchCards(_ userId: String?, for pack: FirebasePack, completion: (() -> Void)? = nil) {
        let userId = userId ?? self.userId
        guard let userId else {
            completion?()
            return
        }
        isLoading = true
        firebaseManager.fetchQuestions(userId, for: pack.pack) { [weak self] cards in
            self?.cards = cards
            self?.isLoading = false
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
    
    func uploadPack(_ pack: Pack) {
        firebaseManager.uploadPack(pack) { [weak self] _ in
            self?.needToUpdate = true
        }
    }
    
    func createPack(_ pack: Pack, tags: [String]) {
        firebaseManager.createPack(pack, tags: tags) { [weak self] _ in
            self?.needToUpdate = true
        }
    }
    
    func createQuestion(_ question: Card) {
        guard let selectedSavingType else { return }
        firebaseManager.createQuestion(question, for: selectedSavingType.id) { [weak self] _ in
            self?.needToUpdate = true
        }
    }
    
    func deletePack(_ pack: Pack) {
        isLoading = true
        firebaseManager.deletePack(pack.id) { [weak self] success in
            self?.isLoading = false
            self?.needToUpdate = true
        }
    }
    
    func deleteQuestion(_ question: Card, for pack: Pack) {
        isLoading = true
        firebaseManager.deleteQuestion(question.id, for: pack) { [weak self] success in
            self?.isLoading = false
            self?.needToUpdate = true
        }
    }
    
    func deleteQuestions(for pack: Pack) {
        guard !selectedCards.isEmpty else { return }
        isLoading = true
        let group = DispatchGroup()
        if pack == favorites.pack {
            for card in selectedCards {
                group.enter()
                firebaseManager.removeQuestionFromFavorites(card) { success in
                    group.leave()
                }
            }
        } else {
            for card in selectedCards {
                group.enter()
                firebaseManager.deleteQuestion(card.id, for: pack) { success in
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.needToUpdate = true
        }
    }
    
    func addToFavorites(_ question: Card) {
        firebaseManager.addQuestionToFavorites(question) { [weak self] success in
            if success,
               let self {
                DispatchQueue.main.async {
                    var fav = self.favorites
                    fav.pack.cards.append(question)
                    fav.cards += 1
                    self.favorites = fav
                }
            }
        }
    }
    
    func removeFromFavorites(_ question: Card) {
        firebaseManager.removeQuestionFromFavorites(question) { [weak self] success in
            if success,
               let self,
               let index = self.favorites.pack.cards.firstIndex(of: question) {
                DispatchQueue.main.async {
                    var fav = self.favorites
                    fav.pack.cards.remove(at: index)
                    fav.cards = fav.cards > 0 ? fav.cards - 1 : 0
                    self.favorites = fav
                }
            }
        }
    }
    
    func isSelected() -> Bool {
        selectedCards == cards
    }
    
    func shuffle() {
        cards = cards.shuffled()
    }
    
    func updateUserName(_ newName: String) {
        isLoading = true
        firebaseManager.updateName(newName) { [weak self] _ in
            self?.isLoading = false
        }
    }
    
}
