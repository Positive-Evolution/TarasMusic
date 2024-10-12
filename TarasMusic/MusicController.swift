import UIKit
import AVFoundation
import SnapKit

class MusicController: UIViewController {
    
    // MARK: - UI Элементы
    private lazy var elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        return label
    }()
    
    private lazy var remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        return label
    }()
    
    private lazy var slider: UISlider = {
        let view = UISlider()
        view.minimumValue = 0.0
        view.value = 0.0
        view.tintColor = UIColor(named: "ButtonsColor")
        view.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let play = UIButton()
        play.addTarget(self, action: #selector(playButtonDidTap), for: .touchUpInside)
        play.setImage(UIImage(systemName: "play.fill"), for: .normal)
        play.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        play.backgroundColor = UIColor(named: "ButtonsColor")
        play.layer.cornerRadius = 45
        play.clipsToBounds = true
        return play
    }()
    
    private lazy var trackName: UILabel = {
        let track = UILabel()
        track.text = "No Track"
        track.font = UIFont.boldSystemFont(ofSize: 20)
        track.textAlignment = .center
        track.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        return track
    }()
    
    private lazy var singerName: UILabel = {
        let singer = UILabel()
        singer.text = "No Singer"
        singer.font = UIFont.systemFont(ofSize: 16)
        singer.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        singer.textAlignment = .center
        return singer
    }()
    
    private lazy var coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        button.backgroundColor = UIColor(named: "ButtonsColor")
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(previousButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        button.backgroundColor = UIColor(named: "ButtonsColor")
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Свойства
    var musicTracks: [Music] = [] // Массив треков
    private var currentTrackIndex: Int = 0 // Индекс текущего трека
    private let player = AVPlayer()
    private var isPlaying: Bool = false
    private var timer: Timer?

    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        setupUI()
        setupBackButton()
    }
    
    // MARK: - Методы
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }, for: .normal)
        backButton.backgroundColor = UIColor(named: "ButtonsColor")
        backButton.layer.cornerRadius = 20
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    public func insertMusic(music: Music) {
        trackName.text = music.title
        singerName.text = music.singer
        slider.value = 0
        
        if let coverImageName = music.coverImageName,
           let cover = UIImage(named: coverImageName) {
            coverImage.image = cover
        } else {
            coverImage.image = UIImage(named: "defaultCoverImage")
        }
        
        currentTrackIndex = musicTracks.firstIndex(where: { $0.title == music.title }) ?? 0
        startMusic()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }

    public func loadTracks(tracks: [Music]) {
        self.musicTracks = tracks
        if !musicTracks.isEmpty {
            insertMusic(music: musicTracks[0])
        }
    }
    
    @objc private func sliderDidChangeValue(_ sender: UISlider) {
        let value = sender.value
        let newTime = CMTime(seconds: Double(value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: newTime)
    }
    
    @objc private func playButtonDidTap() {
        if isPlaying {
            pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            if player.currentItem != nil {
                unPause()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                startMusic()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
        isPlaying.toggle()
    }
    
    private func pause() {
        player.pause()
        timer?.invalidate()
    }
    
    private func unPause() {
        player.play()
        startTimer()
    }
    
    private func startMusic() {
        guard !musicTracks.isEmpty, currentTrackIndex < musicTracks.count else { return }

        let music = musicTracks[currentTrackIndex]
        let url = music.url
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        slider.maximumValue = Float(music.duration) // Устанавливаем максимальное значение слайдера на длину трека
        player.play()
        
        // Сбрасываем значение слайдера и меток времени
        slider.value = 0
        elapsedTimeLabel.text = "0:00"
        remainingTimeLabel.text = "-\(formatTime(music.duration))"

        startTimer() // Запускаем таймер для обновления времени
    }

    private func startTimer() {
        timer?.invalidate() // Остановка предыдущего таймера, если он был
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSliderAndLabels), userInfo: nil, repeats: true)
    }

    @objc private func updateSliderAndLabels() {
        let currentTime = player.currentTime()
        slider.value = Float(CMTimeGetSeconds(currentTime))
        if let currentItem = player.currentItem {
            let duration = CMTimeGetSeconds(currentItem.asset.duration)
            updateTimeLabels(elapsedTime: CMTimeGetSeconds(currentTime), duration: duration)
        }
    }

    private func updateTimeLabels(elapsedTime: Double, duration: Double) {
        let remainingTime = duration - elapsedTime
        elapsedTimeLabel.text = formatTime(elapsedTime)
        remainingTimeLabel.text = "-\(formatTime(remainingTime))"
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }

    @objc private func nextButtonDidTap() {
        if musicTracks.isEmpty { return }
        currentTrackIndex = (currentTrackIndex + 1) % musicTracks.count // Переключаем на следующий трек
        insertMusic(music: musicTracks[currentTrackIndex]) // Обновляем текущий трек
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Устанавливаем кнопку на паузу
    }

    @objc private func previousButtonDidTap() {
        if musicTracks.isEmpty { return }
        currentTrackIndex = (currentTrackIndex - 1 + musicTracks.count) % musicTracks.count // Переключаем на предыдущий трек
        insertMusic(music: musicTracks[currentTrackIndex]) // Обновляем текущий трек
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Устанавливаем кнопку на паузу
    }
    
    @objc private func backButtonDidTap() {
        dismiss(animated: true, completion: nil) // Закрываем текущий контроллер
    }
    
    // MARK: - Настройка UI
    private func setupUI() {
        // Создаём стек для меток
        let labelsStack = UIStackView(arrangedSubviews: [singerName, trackName])
        labelsStack.axis = .vertical
        labelsStack.spacing = 8 // Сохранить старый отступ между singerName и trackName
        labelsStack.alignment = .center
        labelsStack.distribution = .equalSpacing
        
        // Добавляем coverImage в view
        view.addSubview(coverImage)
        
        // Создаём стек для кнопок Previous, Play, Next
        let buttonsStack = UIStackView(arrangedSubviews: [previousButton, playButton, nextButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 16 // Отступы между кнопками
        buttonsStack.alignment = .center
        buttonsStack.distribution = .equalCentering
        
        // Создаём стек для слайдера и кнопок
        let controlsStack = UIStackView(arrangedSubviews: [slider, buttonsStack])
        controlsStack.axis = .vertical
        controlsStack.spacing = 24
        controlsStack.alignment = .center
        
        // Добавляем стеки на главный view
        view.addSubview(labelsStack)
        view.addSubview(controlsStack)
        
        // Устанавливаем констрейнты для labelsStack
        labelsStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40) // Отступ сверху
            make.left.right.equalTo(view).inset(20) // Отступы слева и справа
        }
        
        // Устанавливаем констрейнты для coverImage
        coverImage.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).multipliedBy(0.58) // Устанавливаем 40% от верха экрана
            make.width.equalToSuperview().multipliedBy(0.85) // Ширина 85% от родительского view
            make.height.equalTo(300) // Высота обложки
            make.centerX.equalTo(view) // Центрирование по горизонтали
        }
        
        // Устанавливаем констрейнты для controlsStack
        controlsStack.snp.makeConstraints { make in
            make.centerX.equalTo(view) // Центрирование по горизонтали
            make.left.right.equalTo(view).inset(20) // Отступы слева и справа
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).multipliedBy(0.85) // Отступ от нижней части экрана 15%
        }
        
        // Устанавливаем ширину слайдера относительно родительского view
        slider.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8) // 80% ширины родительского view
        }
        
        // Устанавливаем размеры для playButton и кнопок переключения треков
        playButton.snp.makeConstraints { make in
            make.width.height.equalTo(90) // Размер 90x90 для playButton
        }
        
        previousButton.snp.makeConstraints { make in
            make.width.height.equalTo(70) // Размер 70x70 для кнопки назад
        }
        
        nextButton.snp.makeConstraints { make in
            make.width.height.equalTo(70) // Размер 70x70 для кнопки вперёд
        }

        // Добавляем метки времени
        view.addSubview(elapsedTimeLabel)
        view.addSubview(remainingTimeLabel)

        // Устанавливаем констрейнты для меток времени
        elapsedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(5) // Отступ сверху
            make.left.equalTo(slider) // Привязываем к левому краю слайдера
        }
        
        remainingTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(5) // Отступ сверху
            make.right.equalTo(slider) // Привязываем к правому краю слайдера
        }
    }
}
