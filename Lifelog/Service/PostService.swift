//
//  PostService.swift
//  FirebaseDemo
//
//  Created by user on 2020/5/19.


import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

final class PostService {
    
    // MARK: - Properties
    
    static let shared: PostService = PostService()
    static let uid = Auth.auth().currentUser?.uid
    private init() { }
    // MARK: - Firebase Database References
    
    let baseDbRef: DatabaseReference = Database.database().reference()
    
    let postDbRef: DatabaseReference = Database.database().reference().child("user")
    // MARK: - Firebase Storage Reference
    
    let photoSTorageRef: StorageReference = Storage.storage().reference().child("photo")
    
    
    func uploadImage(image: UIImage, completionHandler: @escaping () -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}

        let postDatabaseRef = postDbRef.child(uid).childByAutoId()

        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = postDatabaseRef.key else {
            return
        }
        
        let imageStorageRef = photoSTorageRef.child("\(imageKey).jpg")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 640.0)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.9) else {
            return
        }
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata) { metadata, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            imageStorageRef.downloadURL { (url, error) in
                guard let displayName = Auth.auth().currentUser?.displayName else {
                    return
                }
                
                guard let url = url else {
                    return
                }
                
                // Add a reference in the database
                let imageFileURL = url.absoluteString
                let photoURL = Auth.auth().currentUser?.photoURL?.absoluteString
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let post: [String : Any] = ["imageFileURL" : imageFileURL,
                                            "userPhoto" : photoURL ?? "error",
                                            "votes" : like,
                                            "user" : displayName,
                                            "timestamp" : timestamp,
                                            "uid": uid
                                            ]
                postDatabaseRef.setValue(post)
                
            }
            
            completionHandler()
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Uploading \(imageKey).jpg... \(percentComplete)% complete")
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    

    
  
    
    func getRecentPosts(start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        print(userUid)
      
        let postDatabaseRef = postDbRef.child(userUid)
        
        var postQuery = postDatabaseRef.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
          
            postQuery = postQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        } else {
            postQuery = postQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        postQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            var newPosts: [Post] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let postInfo = item.value as? [String: Any] ?? [:]
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            if newPosts.count > 0 {
                // Order in descending order (i.e. the latest post becomes the first post)
                newPosts.sort(by: { $0.timestamp > $1.timestamp })
            }
            completionHandler(newPosts)
            
        })
    }
    
    func getOldPosts(start timestamp: Int, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        let postOrderedQuery = postDbRef.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        let postLimitedQuery = postOrderedQuery.queryEnding(atValue: timestamp - 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        
        postLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [Post] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                print("Post key: \(item.key)")
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            
            // Order in descending order (i.e. the latest post becomes the first post)
            newPosts.sort(by: { $0.timestamp > $1.timestamp })
            
            completionHandler(newPosts)
            
        })
        
    }
}
