import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var singerName: UILabel!
        
        let player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singerName.text = "Taras Pypych"
        trackName.text = "Suna"

        view.backgroundColor = UIColor(red: 0.33, green: 0.66, blue: 0.73, alpha: 1.0)
        
        }
    
    @IBAction func touchPlay(_ sender: Any) {
        startMusic()
        player.volume = 0.8
        slider.value = 0
    }
    
    func startMusic() {
        let playerItem = AVPlayerItem(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func playNewTrack() {
        
    }


    func configurePlayButton(with image: UIImage) {
        var configuration = UIButton.Configuration.filled()
        configuration.image = image
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        configuration.imagePlacement = .leading
        playButton.configuration = configuration
    }
    
    func applyDynamicColors() {
        playButton.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.lightGray
        }
    }
}


