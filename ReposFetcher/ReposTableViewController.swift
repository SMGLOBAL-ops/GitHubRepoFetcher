//
//  ReposTableViewController.swift
//  ReposFetcher
//
//  Created by Mustafa, Saif (GT RET Consumer Servicing - Com Bank L, Group Transformation) on 18/11/2022.
//

import UIKit
import Foundation
import SafariServices

struct Repo: Codable {
    let name: String
    let url: URL?
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case url = "html_url"
    }
}

enum FetchReposResult {
    case success([Repo])
    case failure(Error)
}

enum ResponseError: Error {
    case requestUnsuccessful
    case unexpectedResponseStructure
}

class ReposTableViewController: UITableViewController {
    let session = URLSession.shared
    var repos = [Repo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Repos"
//        let repo1 = Repo(name: "Test repo 1", url: URL(string: "http://example.com/repo1")!)
//        let repo2 = Repo(name: "Test repo 2", url: URL(string: "http://example.com/repo2")!)
        fetchRepos(forUsername: "SwiftProgrammingCookbook") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let repos):
                    self?.repos = repos
                case .failure(let error):
                    self?.repos = []
                    print("There was an error \(error)")
                }
                self?.tableView.reloadData()
            }
        }
//        repos.append(contentsOf: [repo1, repo2])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        let repo = repos[indexPath.row]
        cell.textLabel?.text = repo.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = repos[indexPath.row]
        guard let repoURL = repo.url else { return }
        //TODO: Present the repo's URL in a webview
        let webViewController = SFSafariViewController(url: repoURL)
        show(webViewController, sender: nil)
    }
    
    @discardableResult
    internal func fetchRepos(forUsername username: String, completionHandler: @escaping (FetchReposResult) -> Void) -> URLSessionDataTask? {
        let urlString = "https://api.github.com/users/\(username)/repos"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHandler(.failure(ResponseError.requestUnsuccessful))
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode([Repo].self, from: data)
                completionHandler(.success(responseObject))
            } catch {
                completionHandler(.failure(error))
            }
        }
        task.resume()
        
        return task
    }
}

extension ReposTableViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // If no username, clear the data
        guard let enteredUsername = textField.text else {
            repos.removeAll()
            tableView.reloadData()
            return true
        }
        // Fetch repositories from username entered into text field
        fetchRepos(forUsername: enteredUsername) { [weak self] result in
            switch result {
            case .success(let repos):
                self?.repos = repos
            case .failure(let error):
                self?.repos = []
                print("There was an error: \(error)")
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        textField.resignFirstResponder()
        // Returning true as we want the system to have default behaviour
        return true
    }
}
