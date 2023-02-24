import SwiftUI
import Lottie
 
struct LottieView: UIViewRepresentable {
    let lottieFile: String
    let animationView = LottieAnimationView()
    var autoPlay:Bool = true
    var complete: (() -> Void)? = nil
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
 
        animationView.animation = LottieAnimation.named(lottieFile)
        animationView.contentMode = .scaleAspectFill
        if self.autoPlay {
            animationView.play(completion: {_ in
                complete?()
            })
        }
        view.addSubview(animationView)
 
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }
    
    func play(){
        self.animationView.play(completion: {_ in
            complete?()
        })
    }
 
    func updateUIView(_ uiView: UIViewType, context: Context) {
 
    }
}
