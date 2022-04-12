//
//  PostCell.swift
//  Lifelog
//
//  Created by user on 2020/5/19.
//  
import UIKit
import Foundation

var like = 0

class PostCell: UITableViewCell {
    private var currentPost: Post?
    var delegate: FeedTableViewCellDelegate?
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var voteButton: LineButton! {
        didSet {
            voteButton.tintColor = .white
        }
    }
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
            avatarImageView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func shareButton(_ sender: Any) {
        guard let image = self.photoImageView.image else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        delegate?.receiveData(data: activity)
        delegate?.FeedTableViewCellDid(self)
    }
    
    @IBAction func likeButton(_ sender: Any) {
        like += 1
        print(like)
    }
    
    func configure(post: Post) {
        // Set current post
        currentPost = post
        // Set the cell style
        selectionStyle = .none
        
        // Set name and vote count
        nameLabel.text = post.user
        avatarImageView?.kf.setImage(with: URL(string: post.userPhoto ))
        voteButton.setTitle("\(post.votes)", for: .normal)
        voteButton.tintColor = .black
        // Reset image view's image
        photoImageView.image = nil
        
        // Download post image
//        if let image = CacheManager.shared.getFromCache(key: post.imageFileURL) as? UIImage {
//            photoImageView.image = image
//        } else {
            if let url = URL(string: post.imageFileURL) {
                let downloadTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard let imageData = data else {
                        return
                    }
                    OperationQueue.main.addOperation {
                        guard let image = UIImage(data: imageData) else { return }
                        
                        if self.currentPost?.imageFileURL == post.imageFileURL {
                            self.photoImageView.image = image
                        }
                        //Add the downloaded image to cache
                        // CacheManager.shared.cache(object: image, key: post.imageFileURL)
                    }
                    
                })
                
                downloadTask.resume()
            }
        //}
    }
}
