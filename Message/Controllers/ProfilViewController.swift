//
//  ProfilViewController.swift
//  Message
//
//  Created by Hugo on 22/02/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfilViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Se deconnecter"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result{
            case .success(let url):
                self?.donwloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Erreur dans le téléchargement de l'url : \(error)")
            }
        })
        
        return headerView
    }
    
    func donwloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
}

extension ProfilViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertDeco = UIAlertController(title: "Voulez vous vraiment vous déconnecter ?",
                                          message: .none,
                                          preferredStyle: .actionSheet)
        alertDeco.addAction(UIAlertAction(title: "Se deconnecter",
                                          style: .destructive,
                                          handler: { [weak self] _ in
            
            guard let strongSelf = self else{
                return
            }
            
            //Deconnexion Facebook
            FBSDKLoginKit.LoginManager().logOut()
            
            //Deconnexion Google
            GIDSignIn.sharedInstance()?.signOut()
            
            //Deconnexion session Firebase
            do{
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
                
            }
            catch{
                print("Erreur lors de la deconnexion")
            }
        }))
        
        alertDeco.addAction(UIAlertAction(title: "Annuler",
                                          style: .cancel,
                                          handler: nil))
        
        present(alertDeco, animated: true)
    }
}
