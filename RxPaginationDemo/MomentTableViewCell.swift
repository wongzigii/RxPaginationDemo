import UIKit
import SnapKit

final class MomentTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.preferredMaxLayoutWidth = MomentTableViewCellWidth
        label.numberOfLines = 0
        return label
    }()
    
    var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.preferredMaxLayoutWidth = MomentTableViewCellWidth
        label.numberOfLines = 0
        return label
    }()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(15)
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.contentView)
        }
        
        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(self.contentView).offset(-15)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalTo(self.contentView)
        }

    }
    
    func configureWith(post: Post) {
        
        self.titleLabel.text = "\(post.id)"
        self.subTitleLabel.text = post.title
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
