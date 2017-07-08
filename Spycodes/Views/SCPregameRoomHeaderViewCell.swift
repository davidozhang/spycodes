import UIKit

protocol SCPregameRoomHeaderViewCellDelegate: class {
    func onShuffleButtonTapped()
}

class SCPregameRoomHeaderViewCell: SCSectionHeaderViewCell {
    weak var delegate: SCPregameRoomHeaderViewCellDelegate?

    @IBOutlet weak var shuffleButton: SCImageButton!

    @IBAction func onShuffleButtonTapped(_ sender: Any) {
        self.delegate?.onShuffleButtonTapped()
    }

    func hideShuffleButton() {
        self.shuffleButton.isHidden = true
    }

    func showShuffleButton() {
        self.shuffleButton.isHidden = false
    }
}
