//
//  OSImageTableViewCell.swift
//  OperationSample
//
//  Created by Vincent on 07/02/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit
import SnapKit

class OSImageTableViewCell: UITableViewCell {
    lazy var blurImageView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    lazy var aSyncDrawTextView:UITextView = {
        let textView = UITextView.init()
        return textView
    }()
    override func updateConstraints() {
        blurImageView.snp.makeConstraints { (make) in
            make.height.equalTo(contentView.snp.height)
            make.width.equalTo(contentView.snp.height).multipliedBy(0.66)
            make.left.equalTo(0)
            make.top.equalTo(0)
        }
        aSyncDrawTextView.snp.makeConstraints { (make) in
            make.height.equalTo(contentView.snp.height)
            make.left.equalTo(blurImageView.snp.right)
            make.top.equalTo(0)
            make.right.equalTo(contentView.snp.right)
        }
        super.updateConstraints()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(blurImageView)
        contentView.addSubview(aSyncDrawTextView)
        setNeedsUpdateConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
