
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    
    private let db = Firestore.firestore()
    private let users = Firestore.firestore().collection("users")
    private let packKey = "packs"
    private let questionKey = "questions"
    private let favsKey = "favs"
    private let contentKey = "content"
    
    private(set) var user: User?
    
    private var limit: Int = 10
    private var lastDocuments: [String: DocumentSnapshot] = [:]
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error,
               let authError = error as? NSError,
               authError.code == AuthErrorCode.wrongPassword.rawValue {
                completion(false, false)
                return
            }
            if error != nil {
                completion(false, true)
                return
            }
            guard let self else {
                completion(false, true)
                return
            }
            self.user = authResult?.user
            completion(authResult?.user != nil, true)
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self,
                let authResult else {
                completion(false)
                return
            }
            self.user = authResult.user
            
            var userData: [String: Any] = [
                "id": authResult.user.uid,
                "email": authResult.user.email ?? email,
                "displayName": authResult.user.displayName ?? email,
                "opens": 0,
                "createdAt": Timestamp(date: Date())
            ]
            if let url = authResult.user.photoURL {
                userData["photoURL"] = url
            }
            self.users.document(authResult.user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user to Firestore: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("User added to Firestore successfully!")
                    completion(true)
                }
            }
        }
    }
    
    func updateName(_ newName: String, completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error.localizedDescription)")
                completion(false)
            } else {
                self.users.document(user.uid).updateData([
                    "displayName": newName
                ]) { error in
                    if let error = error {
                        print("Error saving user to Firestore: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("User added to Firestore successfully!")
                        completion(true)
                    }
                }
            }
        }
    }
    
    func reset(for email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let _ = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        user = nil
    }
    
    
    func createPack(_ pack: Pack, tags: [String], completion: ((String?) -> Void)? = nil) {
        guard let user else {
            completion?(nil)
            return
        }
        let path = users.document(user.uid).collection(packKey)
        let packId = UUID().uuidString
        
        let data: [String: Any] = [
            "id": packId,
            "userId": user.uid,
            "name": pack.name,
            "description": pack.text,
            "creator": pack.creator,
            "color": pack.color,
            "language": pack.language,
            "tags": tags,
            "opens": 0,
            "createdAt": Timestamp(date: Date()),
            "lastModifiedAt": Timestamp(date: Date())
        ]

        path.document(packId).setData(data) { error in
            if let error = error {
                completion?(nil)
                print("Error creating document: \(error.localizedDescription)")
            } else {
                self.db.collection(self.packKey).document(packId).setData(data) { error in
                    if let error = error {
                        completion?(nil)
                        print("Error creating document: \(error.localizedDescription)")
                    } else {
                        completion?(packId)
                        print("Document created successfully!")
                    }
                }
                print("Document created successfully!")
            }
        }
    }
    
    func uploadPack(_ pack: Pack, completion: ((Bool) -> Void)? = nil) {
        createPack(pack, tags: []) { [weak self] id in
            guard let id else {
                completion?(false)
                return
            }
            let group = DispatchGroup()
            
            for card in pack.cards {
                group.enter()
                self?.createQuestion(card, for: id) { _ in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion?(true)
            }
        }
    }
    
    func createQuestion(_ question: Card, for packId: String, completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let questionId = UUID().uuidString
        let path = users.document(user.uid).collection(packKey)
        
        var data: [String: Any] = [
            "id": questionId,
            "packId": packId,
            "question": question.question,
            "isFlipCard": question.isFlipCard,
            "language": question.language,
            "createdAt": Timestamp(date: Date()),
            "lastModifiedAt": Timestamp(date: Date())
        ]
        if question.isFlipCard {
            data["answer"] = question.answer
        }
        
        path.document(packId).collection(contentKey).document(questionId).setData(data) { error in
            if let error = error {
                completion?(false)
                print("Error creating document: \(error.localizedDescription)")
            } else {
                self.db.collection(self.packKey).document(packId).collection(self.contentKey).document(questionId).setData(data) { error in
                    if let error = error {
                        completion?(false)
                        print("Error creating document: \(error.localizedDescription)")
                    } else {
                        self.db.collection(self.questionKey).document(questionId).setData(data) { error in
                            if let error = error {
                                completion?(false)
                                print("Error creating document: \(error.localizedDescription)")
                            } else {
                                completion?(true)
                                print("Document created successfully!")
                            }
                        }
                        print("Document created successfully!")
                    }
                }
                print("Document created successfully!")
            }
        }
    }
    
    func addQuestionToFavorites(_ question: Card, completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(favsKey)
        
        var data: [String: Any] = [
            "id": question.id,
            "question": question.question,
            "isFlipCard": question.isFlipCard,
            "language": question.language,
            "createdAt": Timestamp(date: Date()),
            "lastModifiedAt": Timestamp(date: Date())
        ]
        if question.isFlipCard {
            data["answer"] = question.answer
        }

        path.document(question.id).setData(data) { error in
            if let error = error {
                completion?(false)
                print("Error adding to favorites document: \(error.localizedDescription)")
            } else {
                completion?(true)
                print("Document added successfully!")
            }
        }
    }
    
    func removeQuestionFromFavorites(_ question: Card, completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(favsKey)
        
        path.document(question.id).delete { error in
            if let error = error {
                completion?(false)
                print("Error adding to favorites document: \(error.localizedDescription)")
            } else {
                completion?(true)
                print("Document removed successfully!")
            }
        }
    }
    
    func deletePack(_ cardTypeId: String, completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(packKey)
        path.document(cardTypeId).delete { error in
            if let error = error {
                completion?(false)
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                self.db.collection(self.packKey).document(cardTypeId).delete { error in
                    if let error = error {
                        completion?(false)
                        print("Error creating document: \(error.localizedDescription)")
                    } else {
                        completion?(true)
                        print("Document created successfully!")
                    }
                }
                print("Document deleted successfully!")
            }
        }
    }
    
    func deleteQuestion(_ questionId: String, for pack: Pack, completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(packKey)
        
        path.document(pack.id).collection(contentKey).document(questionId).delete { error in
            if let error = error {
                completion?(false)
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                self.db.collection(self.packKey).document(pack.id).collection(self.contentKey).document(questionId).delete { error in
                    if let error = error {
                        completion?(false)
                        print("Error creating document: \(error.localizedDescription)")
                    } else {
                        self.db.collection(self.questionKey).document(questionId).delete { error in
                            if let error = error {
                                completion?(false)
                                print("Error creating document: \(error.localizedDescription)")
                            } else {
                                completion?(true)
                                print("Document created successfully!")
                            }
                        }
                        print("Document created successfully!")
                    }
                }
                print("Document deleted successfully!")
            }
        }
    }
    
    func fetchFavorites(_ userId: String? = nil, completion: @escaping (FirebasePack) -> Void) {
        var pack = FirebasePack(pack: Pack(id: UUID().uuidString, name: Localization.onlineFavorites, text: ""), tags: [], user: "", cards: 0)
        pack.pack.color = "D44A13"
        let userId = userId ?? user?.uid
        guard let userId else {
            completion(pack)
            return
        }
        pack.user = userId
        let path = users.document(userId).collection(favsKey)
        path.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion(pack)
                return
            }
            pack.cards = querySnapshot.documents.count
            
            var cards: [Card] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let question = data["question"] as? String ?? "Unknown question"
                let isFlipCard = data["isFlipCard"] as? Bool ?? false
                let answer = data["answer"] as? String
                let language = data["language"] as? String ?? "en"
                
                let card = Card(id: id, question: question)
                card.isFlipCard = isFlipCard
                if let answer, isFlipCard {
                    card.answer = answer
                }
                card.language = language
                cards.append(card)
            }
            pack.pack.cards.append(objectsIn: cards)
            completion(pack)
        }
    }
    
    func fetchMyPacks(completion: @escaping ([FirebasePack]) -> Void) {
        guard let user else {
            completion([])
            return
        }
        let path = users.document(user.uid).collection(packKey)
        path.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            let group = DispatchGroup()
            
            var packs: [FirebasePack] = []
            for document in querySnapshot.documents {
                group.enter()
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let name = data["name"] as? String ?? "Unknown Name"
                let description = data["description"] as? String ?? "Unknown description"
                let color = data["color"] as? String ?? "Unknown color"
                let creator = data["creator"] as? String ?? "me"
                let language = data["language"] as? String ?? "en"
                let tags = data["tags"] as? [String] ?? []
                
                let pack = Pack(id: id, name: name, text: description)
                pack.color = color
                pack.creator = creator
                pack.language = language
                self.getNumberOfCards(path.document(document.documentID).collection(self.contentKey)) { count in
                    let firebasePack = FirebasePack(pack: pack, tags: tags, user: user.uid, cards: count)
                    packs.append(firebasePack)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(packs)
            }
        }
    }
    
    func fetchPacks(_ userId: String? = nil, completion: @escaping ([FirebasePack]) -> Void) {
        if let userId {
            fetchPacksFor(userId, completion: completion)
        } else {
            fetchAllPacks(completion: completion)
        }
    }
    
    private func fetchAllPacks(completion: @escaping ([FirebasePack]) -> Void) {
        var query: Query = db.collection(packKey)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        if let last = lastDocuments["packs"] {
            query = query.start(afterDocument: last)
        }
        query.getDocuments { [weak self] (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  let self,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            let group = DispatchGroup()
            
            var packs: [FirebasePack] = []
            for document in querySnapshot.documents {
                group.enter()
                let data = document.data()
                let userId = data["userId"] as? String ?? UUID().uuidString
                let id = data["id"] as? String ?? UUID().uuidString
                let name = data["name"] as? String ?? "Unknown Name"
                let description = data["description"] as? String ?? "Unknown description"
                let color = data["color"] as? String ?? "Unknown color"
                let creator = data["creator"] as? String ?? "me"
                let language = data["language"] as? String ?? "en"
                let tags = data["tags"] as? [String] ?? []
                
                let pack = Pack(id: id, name: name, text: description)
                pack.color = color
                pack.creator = creator
                pack.language = language
                self.getNumberOfCards(db.collection(packKey).document(document.documentID).collection(self.contentKey)) { count in
                    let firebasePack = FirebasePack(pack: pack, tags: tags, user: userId, cards: count)
                    packs.append(firebasePack)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.lastDocuments["packs"] = querySnapshot.documents.last
                completion(packs)
            }
        }
    }
    
    private func fetchPacksFor(_ userId: String, completion: @escaping ([FirebasePack]) -> Void) {
        let path = users.document(userId).collection(packKey)
        var query: Query = path
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        if let last = lastDocuments["packs_\(userId)"] {
            query = query.start(afterDocument: last)
        }
        query.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            let group = DispatchGroup()
            
            var packs: [FirebasePack] = []
            for document in querySnapshot.documents {
                group.enter()
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let name = data["name"] as? String ?? "Unknown Name"
                let description = data["description"] as? String ?? "Unknown description"
                let color = data["color"] as? String ?? "Unknown color"
                let creator = data["creator"] as? String ?? "me"
                let language = data["language"] as? String ?? "en"
                let tags = data["tags"] as? [String] ?? []
                
                let pack = Pack(id: id, name: name, text: description)
                pack.color = color
                pack.creator = creator
                pack.language = language
                self.getNumberOfCards(path.document(document.documentID).collection(self.contentKey)) { count in
                    let firebasePack = FirebasePack(pack: pack, tags: tags, user: userId, cards: count)
                    packs.append(firebasePack)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.lastDocuments["packs_\(userId)"] = querySnapshot.documents.last
                completion(packs)
            }
        }
    }
    
    private func getNumberOfCards(_ path: CollectionReference, completion: @escaping (Int) -> Void) {
        path.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion(0)
                return
            }
            
            let number = querySnapshot.documents.count
            completion(number)
        }
    }
    
    func fetchQuestions(_ userId: String? = nil, for pack: Pack? = nil, completion: @escaping ([Card]) -> Void) {
        if let userId,
           let pack {
            fetchQuestionsFor(userId, and: pack.id, completion: completion)
        } else if let userId {
            fetchQuestionsFor(userId, completion: completion)
        } else {
            fetchAllQuestions(completion: completion)
        }
    }
    
    private func fetchQuestionsFor(_ userId: String, and id: String, completion: @escaping ([Card]) -> Void) {
        let path = users.document(userId).collection(packKey).document(id).collection(contentKey)
        path.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            
            var packs: [Card] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let question = data["question"] as? String ?? "Unknown question"
                let isFlipCard = data["isFlipCard"] as? Bool ?? false
                let answer = data["answer"] as? String
                let language = data["language"] as? String ?? "en"
                
                let card = Card(id: id, question: question)
                card.isFlipCard = isFlipCard
                if let answer, isFlipCard {
                    card.answer = answer
                }
                card.language = language
                packs.append(card)
            }
            completion(packs)
        }
    }
    
    private func fetchQuestionsFor(_ userId: String, completion: @escaping ([Card]) -> Void) {
        let path = users.document(userId).collection(packKey)
        
        path.getDocuments { [weak self] (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  let self,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            let dispatchGroup = DispatchGroup()
            
            var packs: [Card] = []
            for document in querySnapshot.documents {
                dispatchGroup.enter()
                fetchQuestionsFor(userId, and: document.documentID) {
                    packs.append(contentsOf: $0)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.lastDocuments["questions_\(userId)"] = querySnapshot.documents.last
                completion(packs)
            }
        }
    }
    
    private func fetchAllQuestions(completion: @escaping ([Card]) -> Void) {
        var query: Query = db.collection(questionKey)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        if let last = lastDocuments["questions"] {
            query = query.start(afterDocument: last)
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  let self,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            
            var packs: [Card] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let question = data["question"] as? String ?? "Unknown question"
                let isFlipCard = data["isFlipCard"] as? Bool ?? false
                let answer = data["answer"] as? String
                let language = data["language"] as? String ?? "en"
                
                let card = Card(id: id, question: question)
                card.isFlipCard = isFlipCard
                if let answer, isFlipCard {
                    card.answer = answer
                }
                card.language = language
                packs.append(card)
            }
            self.lastDocuments["questions"] = querySnapshot.documents.last
            completion(packs)
        }
    }
    
    func fetchAllUsers(completion: @escaping ([FirebaseUser]) -> Void) {
        var query: Query = users
            .order(by: "id", descending: true)
            .limit(to: limit)
        
        if let last = lastDocuments["users"] {
            query = query.start(afterDocument: last)
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            
            var users: [FirebaseUser] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let email = data["email"] as? String ?? "Unknown email"
                let displayName = data["displayName"] as? String ?? email
                let photoURL = data["photoURL"] as? URL
                let lastSeen = data["lastSeen"] as? Timestamp
                let lastSeenDate = lastSeen?.dateValue()
                
                let user = FirebaseUser(id: id, email: email, displayName: displayName, photoURL: photoURL, lastSeen: lastSeenDate)
                users.append(user)
            }
            self.lastDocuments["users"] = querySnapshot.documents.last
            completion(users)
        }
    }
    
    func clear() {
        lastDocuments = [:]
    }
    
}
