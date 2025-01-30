
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    
    private let db = Firestore.firestore()
    private let users = Firestore.firestore().collection("users")
    private let packKey = "packs"
    private let favsKey = "favs"
    private let contentKey = "content"
    
    private(set) var user: User?
    
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
    
    
    func createPack(_ pack: Pack, tags: [String], completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(packKey)
        checkExistence(path, id: pack.id) { exists in
            guard !exists else {
                completion?(false)
                return
            }
            let data: [String: Any] = [
                "id": pack.id,
                "name": pack.name,
                "description": pack.text,
                "creator": pack.creator,
                "color": pack.color,
                "language": pack.language,
                "tags": tags,
                "createdAt": Timestamp(date: Date()),
                "lastModifiedAt": Timestamp(date: Date())
            ]

            path.document(pack.id).setData(data) { error in
                if let error = error {
                    completion?(false)
                    print("Error creating document: \(error.localizedDescription)")
                } else {
                    completion?(true)
                    print("Document created successfully!")
                }
            }
        }
    }
    
    func createQuestion(_ question: Card, for pack: Pack, completion: ((Bool) -> Void)? = nil) {
        guard let user else {
            completion?(false)
            return
        }
        let path = users.document(user.uid).collection(packKey)
        checkExistence(path, id: pack.id) { [weak self] exists in
            guard exists, let self else {
                completion?(false)
                return
            }
            var data: [String: Any] = [
                "id": question.id,
                "packId": pack.id,
                "question": question.question,
                "isFlipCard": question.isFlipCard,
                "language": question.language,
                "createdAt": Timestamp(date: Date()),
                "lastModifiedAt": Timestamp(date: Date())
            ]
            if question.isFlipCard {
                data["answer"] = question.answer
            }
            
            path.document(pack.id).collection(contentKey).document(question.id).setData(data) { error in
                if let error = error {
                    completion?(false)
                    print("Error creating document: \(error.localizedDescription)")
                } else {
                    completion?(true)
                    print("Document created successfully!")
                }
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
                print("Document added successfully!")
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
                completion?(true)
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
        checkExistence(path, id: pack.id) { [weak self] exists in
            guard exists, let self else {
                completion?(false)
                return
            }
            
            path.document(pack.id).collection(contentKey).document(questionId).delete { error in
                if let error = error {
                    completion?(false)
                    print("Error deleting document: \(error.localizedDescription)")
                } else {
                    completion?(true)
                    print("Document deleted successfully!")
                }
            }
        }
    }
    
    func fetchFavorites(_ userId: String? = nil, completion: @escaping ([Card]) -> Void) {
        let userId = userId ?? user?.uid
        guard let userId else {
            completion([])
            return
        }
        let path = users.document(userId).collection(favsKey)
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
    
    func fetchMyPacks(completion: @escaping ([FirebasePack]) -> Void) {
        guard let user else {
            completion([])
            return
        }
        fetchPacksFor(user.uid, completion: completion)
    }
    
    func fetchPacks(_ userId: String? = nil, completion: @escaping ([FirebasePack]) -> Void) {
        if let userId {
            fetchPacksFor(userId, completion: completion)
        } else {
            fetchAllPacks(completion: completion)
        }
    }
    
    private func fetchAllPacks(completion: @escaping ([FirebasePack]) -> Void) {
        users.getDocuments { [weak self] (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  let self,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            let dispatchGroup = DispatchGroup()
            
            var packs: [FirebasePack] = []
            for document in querySnapshot.documents {
                dispatchGroup.enter()
                fetchPacksFor(document.documentID) {
                    packs.append(contentsOf: $0)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(packs)
            }
        }
    }
    
    private func fetchPacksFor(_ userId: String, completion: @escaping ([FirebasePack]) -> Void) {
        let path = users.document(userId).collection(packKey)
        path.getDocuments { (querySnapshot, error) in
            if let _ = error { return }
            guard let querySnapshot,
                  !querySnapshot.documents.isEmpty else {
                completion([])
                return
            }
            
            var packs: [FirebasePack] = []
            for document in querySnapshot.documents {
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
                let firebasePack = FirebasePack(pack: pack, tags: tags)
                packs.append(firebasePack)
            }
            completion(packs)
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
                completion(packs)
            }
        }
    }
    
    private func fetchAllQuestions(completion: @escaping ([Card]) -> Void) {
        users.getDocuments { [weak self] (querySnapshot, error) in
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
                fetchQuestionsFor(document.documentID) {
                    packs.append(contentsOf: $0)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion(packs)
            }
        }
    }
    
    func fetchAllUsers(completion: @escaping ([FirebaseUser]) -> Void) {
        users.getDocuments { (querySnapshot, error) in
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
                
                let user = FirebaseUser(id: id, email: email, displayName: displayName, photoURL: photoURL)
                users.append(user)
            }
            print(users)
            completion(users)
        }
    }
    
    private func checkExistence(_ collection: CollectionReference, id: String, completion: @escaping (Bool) -> Void) {
       collection.getDocuments { (querySnapshot, error) in
           if let _ = error { return }
           guard let querySnapshot,
                 !querySnapshot.documents.isEmpty else {
               completion(false)
               return
           }
           
           for document in querySnapshot.documents {
               if document.documentID == id {
                   completion(true)
                   return
               }
           }
           completion(false)
       }
   }
    
}
