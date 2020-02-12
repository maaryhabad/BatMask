//
//  MaskCollectionViewCell.swift
//  
//
//  Created by Mariana Beilune Abad on 05/02/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import UIKit

class MaskCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var maskImage: UIImageView!
    
    private let cornerRadius: CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.cornerRadius = cornerRadius
    }
    
    func setup(with imageName: String) {
        maskImage.image = UIImage(named: imageName)
    }
}
