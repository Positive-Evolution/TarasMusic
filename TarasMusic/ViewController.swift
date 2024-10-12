import UIKit
import SnapKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // MARK: - Свойства
    private var musicList: [Music] = []
    private var filteredMusicList: [Music] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Find Track"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Songs"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        return label
    }()
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        setupTitleLabel()
        setupSearchBar()
        setupTableView()
        
        initializeMusicList()
        filteredMusicList = musicList
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
        }
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.centerX.equalTo(view)
            make.width.equalToSuperview().multipliedBy(0.85)
            searchBar.tintColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .white : .black
            }
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Инициализация треков
    private func initializeMusicList() {
        let urls = [
            URL(string: "https://cdn.pixabay.com/audio/2021/11/01/audio_00fa5593f3.mp3")!,
            URL(string: "https://cdn.pixabay.com/audio/2023/02/16/audio_1b7d87b603.mp3")!,
            URL(string: "https://cdn.pixabay.com/audio/2024/01/04/audio_3469a0e931.mp3")!,
            URL(string: "https://cdn.pixabay.com/audio/2023/06/22/audio_c8437fdaa7.mp3")!,
            URL(string: "https://cdn.pixabay.com/audio/2024/08/27/audio_31ccb8bc93.mp3")!,
            URL(string: "https://cdn.pixabay.com/audio/2023/07/22/audio_34905e0754.mp3")!,
            URL(string: "https://cdn.pixabay.com/audio/2023/10/28/audio_4f15b2fc3a.mp3")!
        ]
        
        let singers = ["Singer1", "Singer2", "Singer3", "Singer4", "Singer5", "Singer6", "Singer7"]
        let titles = ["Track1", "Track2", "Track3", "Track4", "Track5", "Track6", "Track7"]
        
        for (index, url) in urls.enumerated() {
            let duration = getTrackDuration(url: url)
            let coverImageName = "track\(index + 1)Cover"
            let music = Music(url: url, singer: singers[index], title: titles[index], duration: duration, coverImageName: coverImageName)
            musicList.append(music)
        }
    }
    
    private func getTrackDuration(url: URL) -> Double {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMusicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let music = filteredMusicList[indexPath.row]
        cell.textLabel?.text = music.title
        
        if let coverImageName = music.coverImageName,
           let coverImage = UIImage(named: coverImageName) {
            cell.imageView?.image = coverImage
        } else {
            cell.imageView?.image = UIImage(named: "coverImage")
        }
        
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.backgroundColor = UIColor.clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let music = filteredMusicList[indexPath.row]
        let musicController = MusicController()
        musicController.loadTracks(tracks: musicList)
        musicController.insertMusic(music: music)
        present(musicController, animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMusicList = musicList
        } else {
            filteredMusicList = musicList.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}
