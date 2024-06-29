//
//  FirebaseMainManager.swift
//  RimoRimo-Refactoring
//
//  Created by wxxd-fxrest on 6/28/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseMainManager {
    
    static let shared = FirebaseMainManager()
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    var currentUid: String? {
        return auth.currentUser?.uid
    }

    private init() {}

    func fetchUserData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let uid = currentUid else {
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("user-info").document(uid)
        
        docRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let snapshot = documentSnapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }

            let documentData = snapshot.data() ?? [:]
            completion(documentData, nil)
        }
    }
    
    func getStudySession(date: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let uid = currentUid else {
            return
        }
        
         let docRef = db.collection("user-info").document(uid).collection("study-sessions").document(date)
         
         docRef.getDocument { (document, error) in
             if let error = error {
                 completion(.failure(error))
                 return
             }
             
             guard let document = document, document.exists, let data = document.data() else {
                 completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                 return
             }
             
             completion(.success(data))
         }
     }
    
    func getDocument(path: String, day: String, completion: @escaping (Result<DocumentSnapshot, Error>) -> Void) {
          db.collection(path).document(day).getDocument { (document, error) in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              guard let document = document, document.exists else {
                  completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                  return
              }
              completion(.success(document))
          }
      }
      
      func saveData(path: String, day: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
          db.collection(path).document(day).setData(data) { error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              completion(.success(()))
          }
      }
      
      func updateData(path: String, day: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
          db.collection(path).document(day).updateData(data) { error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              completion(.success(()))
          }
      }
      
      func deleteData(path: String, day: String, completion: @escaping (Result<Void, Error>) -> Void) {
          db.collection(path).document(day).delete { error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              completion(.success(()))
          }
      }
    
    func checkAndResetTimerIfNeeded(currentUid: String?, resetTimer: @escaping () -> Void) {
        guard let uid = currentUid else {
            print("유저 정보를 찾을 수 없음")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let day = formatter.string(from: currentDate)
        
        let documentRef = db.collection("user-info").document(uid).collection("study-sessions").document(day)
        
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists {
                // 문서가 존재할 때의 처리
                print("오늘 날짜인 문서가 이미 존재합니다.")
            } else {
                // 문서가 존재하지 않을 때의 처리
                print("오늘 날짜인 문서가 존재하지 않습니다. 타이머를 초기화합니다.")
                
                // 타이머 초기화
                resetTimer()
            }
        }
    }
}
