//
//  PostDetailView.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class PostDetailView: UIView {
    
    var post: Post? {
        didSet {
            updateSubViews()
        }
    }
    
    private let postTitleLabel = UILabel()
    private let authorLabel = UILabel()
    
    override init(frame: CGRect) {
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    func updateSubViews() {
        guard let post = post else { return }
        let author = post.author
        let title = post.title
        
        
        
    }
    
}
