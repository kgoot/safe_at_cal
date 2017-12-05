//
//  ChannelListView.swift
//  WalkMe
//
//  Created by Laptop Lending on 12/4/17.
//  Copyright © 2017 KGLG. All rights reserved.
//  * Copyright (c) 2015 Razeware LLC

import Foundation
import Firebase
import UIKit

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelListViewController: UITableViewController {
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    fileprivate var channels: [Channel] = []


    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            // print('lol wut')
            return 0
        }
        
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" :           "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
    
        return cell
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        channels.append(Channel(id: "1", name: "Channel1"))
        channels.append(Channel(id: "2", name: "Channel2"))
        channels.append(Channel(id: "3", name: "Channel3"))
        self.tableView.reloadData()
    }
}
