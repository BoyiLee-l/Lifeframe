//
//  FeedTableTableViewController.swift
//  Lifelog
//
//  Created by user on 2020/5/19.


import UIKit
import YPImagePicker
import Firebase
import FirebaseStorage


var photoCount : Int?
protocol FeedTableViewCellDelegate {
    func receiveData(data: UIActivityViewController)
    func FeedTableViewCellDid(_ sender:PostCell)
}

class FeedTableViewController: UITableViewController,FeedTableViewCellDelegate{
    var postfeed: [Post] = []
    var thedata = UIActivityViewController(activityItems: [], applicationActivities: nil)
    fileprivate var isLoadingPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //設置下拉式更新
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(loadRecentPosts), for: UIControl.Event.valueChanged)
        // 載入最新的貼文
        //// 我只改這裡
        let ref = Database.database().reference().child("user")
        guard let emailid = Auth.auth().currentUser?.uid else {
            
            return
        }
        ref.child(emailid).observe(DataEventType.childAdded) { (datasnap) in
            print("帳號ＩＤ   \(emailid) == \(datasnap)")
        }
        postfeed = []
        loadRecentPosts()
        tableView.reloadData()
    }

    // MARK: - 相機
    @IBAction func openCamera(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.colors.tintColor = .black
        config.wordings.next = "OK"
        config.showsPhotoFilters = false
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            
            guard let photo = items.singlePhoto
            else {
                picker.dismiss(animated: true, completion: nil)
                
                return
            }
            
            PostService.shared.uploadImage(image: photo.image) {
                picker.dismiss(animated: true, completion: nil)
                self.loadRecentPosts()
            }
            
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - 處理貼文下載與顯示
    @objc fileprivate func loadRecentPosts() {
        
        isLoadingPost = true
        
        PostService.shared.getRecentPosts(start: postfeed.first?.timestamp, limit: 10) { (newPosts) in
            if newPosts.count > 0 {
                // 加上這個陣列至貼文陣列的開始處
                self.postfeed.insert(contentsOf: newPosts, at: 0)
            }
            
            self.isLoadingPost = false
            
            if let _ = self.refreshControl?.isRefreshing {
                // 為了讓動畫效果更佳，在結束更新之前延遲 0.5秒
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.refreshControl?.endRefreshing()
                    self.displayNewPosts(newPosts: newPosts)
                    photoCount = self.postfeed.count
                })
            } else {
                self.displayNewPosts(newPosts: newPosts)
            }
        }
    }
    
    private func displayNewPosts(newPosts posts: [Post]) {
        // Make sure we got some new posts to display
        guard posts.count > 0 else {
            return
        }
        // Display the posts by inserting them to the table view
        var indexPaths:[IndexPath] = []
        self.tableView.beginUpdates()
        for num in 0...(posts.count - 1) {
            let indexPath = IndexPath(row: num, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.endUpdates()
    }
    
    func receiveData(data: UIActivityViewController) {
        self.thedata = data
       }
    
    func FeedTableViewCellDid(_ sender: PostCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        present(thedata , animated: true)
        print(indexPath)
       }
       
    
    
    
}
// MARK: - ImagePicker 委派
//extension FeedTableViewController: ImagePickerDelegate {
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        
//    }
//    
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        // 取得第一張圖片
//        guard let image = images.first else {
//            dismiss(animated: true, completion: nil)
//            return
//        }
//        
//        // Upload image to the cloud
//        PostService.shared.uploadImage(image: image) {
//            self.dismiss(animated: true, completion: nil)
//            self.loadRecentPosts()
//        }
//        
//    }
//    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//}

extension FeedTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        let currentPost = postfeed[indexPath.row]
        cell.configure(post: currentPost)
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postfeed.count
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // We want to trigger the loading when the user reaches the last two rows
        guard !isLoadingPost, postfeed.count - indexPath.row == 2 else {
            return
        }
        isLoadingPost = true
        guard let lastPostTimestamp = postfeed.last?.timestamp else {
            isLoadingPost = false
            return
        }
        PostService.shared.getOldPosts(start: lastPostTimestamp, limit: 3) { (newPosts) in
            // Add new posts to existing arrays and table view
            var indexPaths:[IndexPath] = []
            self.tableView.beginUpdates()
            for newPost in newPosts {
                self.postfeed.append(newPost)
                let indexPath = IndexPath(row: self.postfeed.count - 1, section: 0)
                indexPaths.append(indexPath)
            }
            self.tableView.insertRows(at: indexPaths, with: .fade)
            self.tableView.endUpdates()
            
            self.isLoadingPost = false
        }
    }
}

