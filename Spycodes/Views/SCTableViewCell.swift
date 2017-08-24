import ISEmojiView
import UIKit

protocol SCTableViewCellEmojiDelegate: class {
    func tableViewCell(onEmojiSelected emoji: String)
}

class SCTableViewCell: UITableViewCell {
    weak var emojiDelegate: SCTableViewCellEmojiDelegate?
    var indexPath: IndexPath?

    enum InputType: Int {
        case regular = 0
        case emoji = 1
    }

    @IBOutlet weak var leftLabel: SCLabel!
    @IBOutlet weak var primaryLabel: SCLabel!
    @IBOutlet weak var secondaryLabel: SCLabel!
    @IBOutlet weak var rightLabel: SCLabel!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var rightTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()

        if let _ = self.leftLabel {
            // Pregame modal info view cell specific
            self.leftLabel.font = SCFonts.regularSizeFont(.regular)
        }

        if let _ = self.primaryLabel {
            self.primaryLabel.font = SCFonts.intermediateSizeFont(.regular)
        }

        if let _ = self.secondaryLabel {
            self.secondaryLabel.font = SCFonts.smallSizeFont(.regular)
            self.secondaryLabel.numberOfLines = 2
        }

        if let _ = self.rightLabel {
            self.rightLabel.font = SCFonts.intermediateSizeFont(.bold)
        }

        if let _ = self.rightTextView {
            self.rightTextView.font = SCFonts.intermediateSizeFont(.regular)
            self.rightTextView.tintColor = .clear
        }

        self.backgroundColor = .clear
        self.selectionStyle = .none
    }

    func setInputView(inputType: InputType) {
        switch inputType {
        case .regular:
            break
        case .emoji:
            let emojiView = ISEmojiView()
            emojiView.delegate = self
            self.rightTextView.inputView = emojiView
        }
    }
}

extension SCTableViewCell: ISEmojiViewDelegate {
    func emojiViewDidSelectEmoji(emojiView: ISEmojiView, emoji: String) {
        self.rightTextView.text = emoji
        self.rightTextView.resignFirstResponder()
        self.emojiDelegate?.tableViewCell(onEmojiSelected: emoji)
    }

    func emojiViewDidPressDeleteButton(emojiView: ISEmojiView) {
        self.rightTextView.text = ""
    }
}
