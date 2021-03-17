//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Paul Smith on 1/7/21.
//

import UIKit

private let tableCellIndentifier = "MemeCell"
private let vcIdentifier = "MemeDetailViewController"

class MemeTableViewController: UITableViewController {
        
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView!.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIndentifier)!
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = meme.topText + "-" + meme.bottomText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: vcIdentifier) as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }

    
    @IBAction func createNewMeme(_ sender: Any) {
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditMemeViewController")as! EditMemeViewController
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}
