//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Wu, Qifan | Keihan | ECID on 2017/12/09.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    var memes: [Meme]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memes = AppDelegate.shared.memes
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemesTableViewCell") as! SentMemesTableViewCell
        if let memes = memes {
            cell.memeImage.image = memes[indexPath.row].memedImage
            cell.memeLabel.text = memes[indexPath.row].topText + " " + memes[indexPath.row].bottomText
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let memeDetailVC = segue.destination as! MemeDetailViewController
            let index = sender as! Int
            memeDetailVC.index = index
        }
    }
}
