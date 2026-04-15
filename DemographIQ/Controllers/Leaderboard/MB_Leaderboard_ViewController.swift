//
//  MB_Leaderboard_ViewController.swift
//  DemographIQ
//
//  Created by Michaël Blin on 15/04/2026.
//

import UIKit
import SnapKit

public class MB_Leaderboard_ViewController: MB_ViewController {
    
    private var users:[MB_User]? {
        
        didSet {
            
            containerView.dismissPlaceholder()
            tableView.isHidden = false
            
            if users?.isEmpty ?? true {
                
                containerView.showPlaceholder(.Empty)
                tableView.isHidden = true
            }
            
            tableView.reloadData()
            
            if let index = users?.firstIndex(of: MB_User.current) {
                
                tableView.scrollToRow(at: .init(row: index, section: 0), at: .middle, animated: false)
            }
        }
    }
    private lazy var segmentedControl:MB_SegmentedControl = {
        
        $0.selectedSegmentIndex = 0
        $0.addAction(.init(handler: { [weak self] _ in
            
            self?.updateData()
            
        }), for: .valueChanged)
        return $0
        
    }(MB_SegmentedControl(items: ["leaderboard.segment.classic","leaderboard.segment.plusMinus"].compactMap({ String(key: $0) })))
    private lazy var containerView:UIView = {
        
        $0.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return $0
        
    }(UIView())
    private lazy var tableView:MB_TableView = {
        
        $0.allowsSelection = false
        $0.register(MB_Leaderboard_TableViewCell.self, forCellReuseIdentifier: MB_Leaderboard_TableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
        
    }(MB_TableView())
    
    public override func loadView() {
        
        super.loadView()
        
        isModal = true
        
        navigationItem.title = String(key: "leaderboard.title")
        
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        
        segmentedControl.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.bottom.equalToSuperview().inset(UI.Margins)
            make.top.equalTo(segmentedControl.snp.bottom).offset(UI.Margins)
        }
        
        updateData()
    }
    
    private func updateData() {
        
        containerView.showPlaceholder(.Loading)
        tableView.isHidden = true
        
        MB_User.getLeaderboard { [weak self] error, users in
            
            self?.containerView.dismissPlaceholder()
            self?.tableView.isHidden = false
            
            if let error {
                
                self?.containerView.showPlaceholder(.Error, error) { [weak self] _ in
                    
                    self?.segmentedControl.sendActions(for: .valueChanged)
                }
            }
            else {
                
                self?.users = users?.sorted(by: {
                    
                    self?.segmentedControl.selectedSegmentIndex == 0 ? $0.scores.classic > $1.scores.classic : $0.scores.plusMinus > $1.scores.plusMinus
                    
                }).filter({
                    
                    self?.segmentedControl.selectedSegmentIndex == 0 ? $0.scores.classic > 0 : $0.scores.plusMinus > 0
                })
            }
        }
    }
}

extension MB_Leaderboard_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MB_Leaderboard_TableViewCell = tableView.dequeueReusableCell(withIdentifier: MB_Leaderboard_TableViewCell.identifier, for: indexPath) as! MB_Leaderboard_TableViewCell
        
        let user = users?[indexPath.row]
        
        cell.isUser = user == MB_User.current
        cell.nameLabel.text = user?.name
        cell.rankButton.title = "\(indexPath.row + 1)"
        cell.scoreLabel.text = "\(segmentedControl.selectedSegmentIndex == 0 ? user?.scores.classic ?? 0 : user?.scores.plusMinus ?? 0) " + String(key: "leaderboard.points")
        return cell
        
    }
}
