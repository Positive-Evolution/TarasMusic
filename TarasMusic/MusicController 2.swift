//
//  MusicController 2.swift
//  TarasMusic
//
//  Created by Taras Pypych on 2024-10-16.
//


import UIKit
import AVFoundation
import SnapKit

class MusicController: UIViewController {
    
    // MARK: - UI Элементы
    
    private lazy var slider: UISlider = {
        let view = UISlider()
        view.minimumValue = 0.0
        view.maximumValue = 600.0 // Устанавливаем максимальное значение на 10 минут (600 секунд)
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
            return traitCollection.userInterfaceStyle == .dark ? .white : .black // Динамический цвет
        }
        play.backgroundColor = UIColor(named: "ButtonsColor")
        play.layer.cornerRadius = 45
        play.clipsToBounds = true
        play.imageView?.contentMode = .scaleAspectFit
        return play
    }()
    
    private lazy var trackName: UILabel = {
        let track = UILabel()
        track.text = "No Track"
        track.font = UIFont.boldSystemFont(ofSize: 20)
        track.textAlignment = .center
        track.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black // Динамический цвет
        }
        return track
    }()
    
    private lazy var singerName: UILabel = {
        let singer = UILabel()
        singer.text = "No Singer"
        singer.font = UIFont.systemFont(ofSize: 16)
        singer.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black // Динамический цвет
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
            return traitCollection.userInterfaceStyle == .dark ? .white : .black // Динамический цвет
        }
        button.backgroundColor = UIColor(named: "ButtonsColor")
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(previousButtonDidTap), for: .touchUpInside)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black // Динамический цвет
        }
        button.backgroundColor = UIColor(named: "ButtonsColor")
        button.layer.cornerRadius = 35
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    // MARK: - Свойства
    
    var musicTracks: [MusicTrack] = [] // Массив треков
    private var currentTrackIndex: Int = 0 // Индекс текущего трека
    private let player = AVPlayer()
    private var isPlaying: Bool = false
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        setupUI()
        
        // Настройка кнопки "Назад"
        setupBackButton()
    }
    
    // MARK: - Методы
    
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("<", for: .normal)
        backButton.setTitleColor(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black // Динамический цвет
        }, for: .normal)
        backButton.backgroundColor = UIColor(named: "ButtonsColor") // Используем цвет из Assets
        backButton.layer.cornerRadius = 20
        backButton.clipsToBounds = true
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        view.addSubview(backButton)
        
        // Устанавливаем ограничения для кнопки "Назад"
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20) // Отступ сверху
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20) // Отступ слева
            make.width.equalTo(40) // Ширина кнопки
            make.height.equalTo(40) // Высота кнопки
        }
    }
    
    public func insertMusic(music: MusicTrack) {
        trackName.text = music.title
        singerName.text = music.singer
        slider.value = 0 // Сбрасываем слайдер
        
        // Устанавливаем изображение обложки
        if let cover = music.coverImageName, let image = UIImage(named: cover) {
            coverImage.image = image
        } else {
            coverImage.image = UIImage(named: "defaultCover") // Обложка по умолчанию
        }
    }
    
    public func loadTracks(tracks: [MusicTrack]) {
        self.musicTracks = tracks
        currentTrackIndex = 0
        insertMusic(music: musicTracks[currentTrackIndex]) // Вставляем первый трек
    }
    
    @objc private func sliderDidChangeValue(_ sender: UISlider) {
        let value = sender.value
        let newTime = CMTime(seconds: Double(value), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: newTime)
    }
    
    @objc private func playButtonDidTap() {
        if isPlaying {
            pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal) // Изменяем на play
        } else {
            if player.currentItem != nil {
                unPause()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Изменяем на pause
            } else {
                startMusic()
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Изменяем на pause
            }
        }
        isPlaying.toggle()
    }
    
    private func pause() {
        player.pause()
    }
    
    private func unPause() {
        player.play()
    }
    
    private func startMusic() {
        guard !musicTracks.isEmpty else { return }
        
        let music = musicTracks[currentTrackIndex]
        let url = music.url
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        slider.maximumValue = Float(music.duration) // Устанавливаем максимальное значение слайдера
        player.play()
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] time in
            self?.slider.value = Float(time.seconds)
        }
    }
    
    @objc private func nextButtonDidTap() {
        if musicTracks.isEmpty { return }
        currentTrackIndex = (currentTrackIndex + 1) % musicTracks.count // Переключаем на следующий трек
        insertMusic(music: musicTracks[currentTrackIndex]) // Обновляем текущий трек
        startMusic() // Начинаем воспроизведение
    }
    
    @objc private func previousButtonDidTap() {
        if musicTracks.isEmpty { return }
        currentTrackIndex = (currentTrackIndex - 1 + musicTracks.count) % musicTracks.count // Переключаем на предыдущий трек
        insertMusic(music: musicTracks[currentTrackIndex]) // Обновляем текущий трек
        startMusic() // Начинаем воспроизведение
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
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).multipliedBy(0.53) // Устанавливаем 40% от верха экрана
            make.width.equalToSuperview().multipliedBy(0.85) // Ширина 85% от родительского view
            make.height.equalTo(200) // Высота обложки
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
    }
}