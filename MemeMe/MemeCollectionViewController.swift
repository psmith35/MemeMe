//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Paul Smith on 1/7/21.
//

import UIKit

private let reuseIdentifier = "MemeCollectionViewCell"
private let vcIdentifier = "MemeDetailViewController"
private let segueIdentifier = "createNewMeme"

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let space:CGFloat = 10.0
        let width = (view.frame.size.width - (2 * space)) / space
        let height = (view.frame.size.height - (2 * space)) / space

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView!.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]

        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: vcIdentifier) as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    @IBAction func createNewMeme(_ sender: Any) {
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditMemeViewController")as! EditMemeViewController
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}
