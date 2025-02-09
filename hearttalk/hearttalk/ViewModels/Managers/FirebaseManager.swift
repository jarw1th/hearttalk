
import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    
    private let db = Firestore.firestore()
    private let users = Firestore.firestore().collection("users")
    private let packKey = "packs"
    private let favsKey = "favs"
    private let contentKey = "content"
    
    private(set) var user: User?
    
    private var limit: Int = 10
    private var lastDocuments: [String: DocumentSnapshot] = [:]
    
    init() {
        self.user = Auth.auth().currentUser
    }
    
    // MARK: - Authorization
    func signIn(email: String, password: String, completion: @escaping (Bool, Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error,
               let authError = error as? NSError,
               authError.code == AuthErrorCode.wrongPassword.rawValue {
                completion(false, false)
                return
            }
            guard let self,
                error == nil else {
                completion(false, true)
                return
            }
            self.user = authResult?.user
            completion(authResult?.user != nil, true)
        }
    }
    
    func delete(_ password: String, completion: @escaping (Bool) -> Void) {
        guard let user,
                let email = user.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(false)
                return
            }
            
            let id = user.uid
            user.delete { [weak self] _ in
                self?.signOut()
                self?.deleteAccount(id, completion: completion)
            }
        }
    }
    
    private func deleteAccount(_ id: String, completion: @escaping (Bool) -> Void) {
        delete(users.document(id), completion: completion)
    }
    
    func updatePassword(newPassword: String, completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        user.updatePassword(to: newPassword) { [weak self] error in
            if error != nil {
                completion(false)
            } else {
                self?.user = Auth.auth().currentUser
                completion(true)
            }
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
                "isShowEmail": true,
                "isShowMyContent": true,
                "isShowMyProfile": true,
                "isShowStatus": true,
                "createdAt": Timestamp(date: Date())
            ]
            if let url = authResult.user.photoURL {
                userData["photoURL"] = url.absoluteString
            }
            self.setData(userData, path: self.users.document(authResult.user.uid), completion: completion)
        }
    }
    
    func updateName(_ newName: String, completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        
        changeRequest.commitChanges { [weak self] error in
            if let error = error {
                completion(false)
            } else {
                self?.updateData(["displayName": newName], path: self?.users.document(user.uid)) { success in
                    if success {
                        self?.user = Auth.auth().currentUser
                    }
                    completion(success)
                }
            }
        }
    }
    
    func updatePrivacy(_ privacy: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        
        updateData(privacy, path: users.document(user.uid), completion: completion)
    }
    
    func updateImage(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        
        uploadImage(image: image) { [weak self] url in
            guard let url,
                  let self else {
                completion(false)
                return
            }
            
            setData(["photoUrl": url.absoluteString], path: users.document(user.uid), completion: completion)
        }
    }
    
    private func uploadImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let user,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("images/\(user.uid).jpg")
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let _ = error {
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(url)
                } else {
                    completion(nil)
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
    
    // MARK: - Internal
    private func setData(_ data: [String: Any], path: DocumentReference?, completion: ((Bool) -> Void)? = nil) {
        guard let path else {
            completion?(false)
            return
        }
        path.setData(data) { error in
            completion?(error != nil)
        }
    }
    
    private func updateData(_ data: [String: Any], path: DocumentReference?, completion: ((Bool) -> Void)? = nil) {
        guard let path else {
            completion?(false)
            return
        }
        path.updateData(data) { error in
            completion?(error != nil)
        }
    }
    
    private func getDocuments(_ path: CollectionReference?, completion: ((QuerySnapshot?) -> Void)? = nil) {
        guard let path else {
            completion?(nil)
            return
        }
        path.getDocuments { (querySnapshot, error) in
            guard let querySnapshot,
                  error == nil,
                  !querySnapshot.documents.isEmpty else {
                completion?(nil)
                return
            }
            completion?(querySnapshot)
        }
    }
    
    private func getDocuments(_ query: Query?, completion: ((QuerySnapshot?) -> Void)? = nil) {
        guard let query else {
            completion?(nil)
            return
        }
        query.getDocuments { (querySnapshot, error) in
            guard let querySnapshot,
                  error == nil,
                  !querySnapshot.documents.isEmpty else {
                completion?(nil)
                return
            }
            completion?(querySnapshot)
        }
    }
    
    private func getDocument(_ path: DocumentReference?, completion: ((DocumentSnapshot?) -> Void)? = nil) {
        guard let path else {
            completion?(nil)
            return
        }
        path.getDocument { (documentSnapshot, error) in
            guard let documentSnapshot,
                  error == nil else {
                completion?(nil)
                return
            }
            completion?(documentSnapshot)
        }
    }
    
    private func delete(_ path: DocumentReference?, completion: ((Bool) -> Void)? = nil) {
        guard let path else {
            completion?(false)
            return
        }
        path.delete { error in
            completion?(error != nil)
        }
    }
    
    // MARK: - FireStore
    func fetchMyUser(completion: @escaping (FirebaseUser?) -> Void) {
        guard let user else {
            completion(nil)
            return
        }
        
        getDocument(users.document(user.uid)) { documentSnapshot in
            guard let documentSnapshot else {
                completion(nil)
                return
            }
            
            let data = documentSnapshot.data()
            let id = data?["id"] as? String ?? UUID().uuidString
            let email = data?["email"] as? String ?? "Unknown email"
            let displayName = data?["displayName"] as? String ?? email
            let photoURLstring = data?["photoURL"] as? String ?? ""
            let photoURL = URL(string: photoURLstring)
            let isShowEmail = data?["isShowEmail"] as? Bool ?? false
            let isShowMyContent = data?["isShowMyContent"] as? Bool ?? false
            let isShowMyProfile = data?["isShowMyProfile"] as? Bool ?? false
            let isShowStatus = data?["isShowStatus"] as? Bool ?? false
            let lastSeen = data?["lastSeen"] as? Timestamp
            let lastSeenDate = lastSeen?.dateValue()
            
            let user = FirebaseUser(id: id, email: email, displayName: displayName, photoURL: photoURL, lastSeen: lastSeenDate, isShowEmail: isShowEmail, isShowMyContent: isShowMyContent, isShowStatus: isShowStatus, isShowMyProfile: isShowMyProfile)
            completion(user)
            print(user)
        }
    }
    
    func createPack(_ pack: Pack, tags: [String], showPack: Bool, completion: ((String?) -> Void)? = nil) {
        setUserOnline()
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
            "isShowPack": showPack,
            "opens": 0,
            "createdAt": Timestamp(date: Date()),
            "lastModifiedAt": Timestamp(date: Date())
        ]

        setData(data, path: path.document(packId)) { success in
            if success {
                completion?(packId)
            } else {
                completion?(nil)
            }
        }
    }
    
    func updatePack(_ info: [String: Any], for pack: Pack, completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        
        updateData(info, path: users.document(user.uid).collection(packKey).document(pack.id), completion: completion)
    }
    
    func uploadPack(_ pack: Pack, completion: ((Bool) -> Void)? = nil) {
        createPack(pack, tags: [], showPack: false) { [weak self] id in
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
        setUserOnline()
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
        
        setData(data, path: path.document(packId).collection(contentKey).document(questionId), completion: completion)
    }
    
    func updateQuestion(_ info: [String: Any], for card: Card, and packId: String, completion: @escaping (Bool) -> Void) {
        guard let user else {
            completion(false)
            return
        }
        
        updateData(info, path: users.document(user.uid).collection(packKey).document(packId).collection(contentKey).document(card.id), completion: completion)
    }
    
    func addQuestionToFavorites(_ question: Card, completion: ((Bool) -> Void)? = nil) {
        setUserOnline()
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
        setUserOnline()
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
        setUserOnline()
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(packKey).document(cardTypeId)
        
        getDocuments(path.collection(contentKey)) { [weak self] querySnapshot in
            guard let querySnapshot,
                  let self,
                  !querySnapshot.documents.isEmpty else {
                self?.delete(path, completion: completion)
                return
            }
            let group = DispatchGroup()
            for document in querySnapshot.documents {
                group.enter()
                delete(path.collection(contentKey).document(document.documentID)) { _ in
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.delete(path, completion: completion)
            }
        }
    }
    
    func deleteQuestion(_ questionId: String, for pack: Pack, completion: ((Bool) -> Void)? = nil) {
        setUserOnline()
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(packKey)
        
        delete(users.document(user.uid).collection(favsKey).document(questionId))
        delete(path.document(pack.id).collection(contentKey).document(questionId), completion: completion)
    }
    
    func fetchFavorites(_ userId: String? = nil, completion: @escaping (FirebasePack) -> Void) {
        var pack = FirebasePack(pack: Pack(id: UUID().uuidString, name: Localization.onlineFavorites, text: ""), tags: [], user: "", cards: 0, showPack: true)
        pack.pack.color = "D44A13"
        let userId = userId ?? user?.uid
        guard let userId else {
            completion(pack)
            return
        }
        pack.user = userId
        let path = users.document(userId).collection(favsKey)
        getDocuments(path) { querySnapshot in
            guard let querySnapshot else {
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
        getDocuments(path) { querySnapshot in
            guard let querySnapshot else {
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
                let isShowPackNum = data["isShowPack"] as? NSNumber ?? 1
                let isShowPack = Bool(exactly: isShowPackNum) ?? true
                let creator = data["creator"] as? String ?? "me"
                let language = data["language"] as? String ?? "en"
                let tags = data["tags"] as? [String] ?? []
                
                let pack = Pack(id: id, name: name, text: description)
                pack.color = color
                pack.creator = creator
                pack.language = language
                self.getNumberOfCards(path.document(document.documentID).collection(self.contentKey)) { count in
                    let firebasePack = FirebasePack(pack: pack, tags: tags, user: user.uid, cards: count, showPack: isShowPack)
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
        var query: Query = db.collectionGroup(packKey)
//            .whereField("isShowPack", isEqualTo: true)
            .limit(to: limit)
        
        if let last = lastDocuments["packs"] {
            query = query.start(afterDocument: last)
        }
        getDocuments(query) { [weak self] querySnapshot in
            guard let querySnapshot,
                  let self else {
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
                let isShowPack = data["isShowPack"] as? Bool ?? true
                let creator = data["creator"] as? String ?? "me"
                let language = data["language"] as? String ?? "en"
                let tags = data["tags"] as? [String] ?? []
                
                let pack = Pack(id: id, name: name, text: description)
                pack.color = color
                pack.creator = creator
                pack.language = language
                self.getNumberOfCards(users.document(userId).collection(packKey).document(document.documentID).collection(self.contentKey)) { count in
                    let firebasePack = FirebasePack(pack: pack, tags: tags, user: userId, cards: count, showPack: isShowPack)
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
        getDocuments(query) { querySnapshot in
            guard let querySnapshot else {
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
                let isShowPack = data["isShowPack"] as? Bool ?? true
                let creator = data["creator"] as? String ?? "me"
                let language = data["language"] as? String ?? "en"
                let tags = data["tags"] as? [String] ?? []
                
                let pack = Pack(id: id, name: name, text: description)
                pack.color = color
                pack.creator = creator
                pack.language = language
                self.getNumberOfCards(path.document(document.documentID).collection(self.contentKey)) { count in
                    let firebasePack = FirebasePack(pack: pack, tags: tags, user: userId, cards: count, showPack: isShowPack)
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
        getDocuments(path) { querySnapshot in
            guard let querySnapshot else {
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
        
        getDocuments(path) { querySnapshot in
            guard let querySnapshot else {
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
        
        getDocuments(path) { [weak self] querySnapshot in
            guard let querySnapshot else {
                completion([])
                return
            }
            let dispatchGroup = DispatchGroup()
            
            var packs: [Card] = []
            for document in querySnapshot.documents {
                dispatchGroup.enter()
                self?.fetchQuestionsFor(userId, and: document.documentID) {
                    packs.append(contentsOf: $0)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self?.lastDocuments["questions_\(userId)"] = querySnapshot.documents.last
                completion(packs)
            }
        }
    }
    
    private func fetchAllQuestions(completion: @escaping ([Card]) -> Void) {
        var query: Query = db.collectionGroup(contentKey)
            .limit(to: limit)
        
        if let last = lastDocuments["questions"] {
            query = query.start(afterDocument: last)
        }
        
        getDocuments(query) { querySnapshot in
            guard let querySnapshot else {
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
            .whereField("isShowMyProfile", isEqualTo: true)
            .limit(to: limit)
        
        if let last = lastDocuments["users"] {
            query = query.start(afterDocument: last)
        }
        
        getDocuments(query) { querySnapshot in
            guard let querySnapshot else {
                completion([])
                return
            }
            
            var users: [FirebaseUser] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let id = data["id"] as? String ?? UUID().uuidString
                let email = data["email"] as? String ?? "Unknown email"
                let displayName = data["displayName"] as? String ?? email
                let photoURLstring = data["photoURL"] as? String ?? ""
                let photoURL = URL(string: photoURLstring)
                let isShowEmail = data["isShowEmail"] as? Bool ?? false
                let isShowMyContent = data["isShowMyContent"] as? Bool ?? false
                let isShowMyProfile = data["isShowMyProfile"] as? Bool ?? false
                let isShowStatus = data["isShowStatus"] as? Bool ?? false
                let lastSeen = data["lastSeen"] as? Timestamp
                let lastSeenDate = lastSeen?.dateValue()
                
                let user = FirebaseUser(id: id, email: email, displayName: displayName, photoURL: photoURL, lastSeen: lastSeenDate, isShowEmail: isShowEmail, isShowMyContent: isShowMyContent, isShowStatus: isShowStatus, isShowMyProfile: isShowMyProfile)
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
