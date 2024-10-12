//
//  ViewController 2.swift
//  TarasMusic
//
//  Created by Taras Pypych on 2024-10-14.
//


import UIKit
import AVFoundation
import SnapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Свойства
    let musicList: [Music] = [
        .init(url: URL(string: "https://cdn.pixabay.com/audio/2024/10/01/audio_d9e2d28b63.mp3")!, singer: "Singer1", title: "Track1", duration: 30),
        .init(url: URL(string: "https://cdn.pixabay.com/audio/2023/02/16/audio_1b7d87b603.mp3")!, singer: "Singer2", title: "Track2", duration: 30),
        .init(url: URL(string: "https://cdn.pixabay.com/audio/2024/10/01/audio_d9e2d28b63.mp3")!, singer: "Singer3", title: "Track3", duration: 30),
        .init(url: URL(string: "https://cdn.pixabay.com/audio/2024/10/01/audio_d9e2d28b63.mp3")!, singer: "Singer4", title: "Track4", duration: 30),
        .init(url: URL(string: "https://cdn.pixabay.com/audio/2024/10/01/audio_d9e2d28b63.mp3")!, singer: "Singer5", title: "Track5", duration: 30),
        .init(url: URL(string: "https://cdn.pixabay.com/audio/2024/10/01/audio_d9e2d28b63.mp3")!, singer: "Singer6", title: "Track6", duration: 30)
    ]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = musicList[indexPath.row].title
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = musicList[indexPath.row]
        let musicController = MusicController()
        musicController.loadTracks(tracks: musicList) // Передаём массив треков
        musicController.insertMusic(music: music) // Вставляем выбранный трек
        present(musicController, animated: true)
    }
}