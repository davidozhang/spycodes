import UIKit

class SCTimelineModalViewController: SCModalViewController {
    fileprivate var refreshTimer: Foundation.Timer?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingSpaceConstraint: NSLayoutConstraint!

    deinit {
        print("[DEINIT] " + NSStringFromClass(type(of: self)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableViewBottomSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewLeadingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableViewTrailingSpaceConstraint.constant = SCViewController.tableViewMargin
        self.tableView.layoutIfNeeded()

        self.refreshTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(SCTimelineModalViewController.refreshView),
            userInfo: nil,
            repeats: true
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil

        self.refreshTimer?.invalidate()
    }

    override func onDismissal() {
        if self.tableView.contentOffset.y > 0 {
            return
        }

        super.onDismissal()
    }

    @objc
    fileprivate func refreshView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//   _____      _                 _
//  | ____|_  _| |_ ___ _ __  ___(_) ___  _ __  ___
//  |  _| \ \/ / __/ _ \ '_ \/ __| |/ _ \| '_ \/ __|
//  | |___ >  <| ||  __/ | | \__ \ | (_) | | | \__ \
//  |_____/_/\_\\__\___|_| |_|___/_|\___/|_| |_|___/

// MARK: UITableViewDelegate, UITableViewDataSource
extension SCTimelineModalViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Timeline.instance.getEvents().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = Timeline.instance.getEvents()[indexPath.row]

        if event.getType() == .endRound {
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.sectionHeaderCell.rawValue
            ) as? SCSectionHeaderViewCell else {
                return UITableViewCell()
            }

            if let parameters = event.getParameters(),
               let teamAsInt = parameters[SCConstants.coding.team.rawValue] as? Int {
                let team = Team(rawValue: teamAsInt)
                if team == .red {
                    cell.primaryLabel.text = "Team Red"
                } else {
                    cell.primaryLabel.text = "Team Blue"
                }
            }

            return cell
        } else {
            guard let cell = self.tableView.dequeueReusableCell(
                withIdentifier: SCConstants.identifier.timelineViewCell.rawValue
                ) as? SCTimelineViewCell else {
                    return UITableViewCell()
            }

            if let parameters = event.getParameters() {
                if event.getType() == .confirm {
                    if let name = parameters[SCConstants.coding.name.rawValue] as? String,
                       let clue = parameters[SCConstants.coding.clue.rawValue] as? String,
                       let numberOfWords = parameters[SCConstants.coding.numberOfWords.rawValue] as? String {
                        let attributedString = NSMutableAttributedString(
                            string: name + " set clue '" + clue + " " + numberOfWords + "'"
                        )
                        attributedString.addAttribute(
                            NSFontAttributeName,
                            value: SCFonts.intermediateSizeFont(.bold) ?? 0,
                            range: NSMakeRange(
                                0,
                                name.characters.count
                            )
                        )
                        cell.primaryLabel.attributedText = attributedString
                    }
                } else if event.getType() == .selectCard {
                    if let name = parameters[SCConstants.coding.name.rawValue] as? String,
                       let word = parameters[SCConstants.coding.word.rawValue] as? String {
                        let attributedString = NSMutableAttributedString(
                            string: name + " selected '" + word + "'"
                        )
                        attributedString.addAttribute(
                            NSFontAttributeName,
                            value: SCFonts.intermediateSizeFont(.bold) ?? 0,
                            range: NSMakeRange(
                                0,
                                name.characters.count
                            )
                        )
                        cell.primaryLabel.attributedText = attributedString
                    }
                }
            }

            return cell
        }
    }
}
