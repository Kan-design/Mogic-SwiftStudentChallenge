import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: CGFloat = 0.0
    @State private var ripplePlace:CGFloat = 100
    
    var body: some View {
        if isActive {
            ContentView()
        }else {
            Color(hex: 0xE0E5EC)
                .ignoresSafeArea()
                .overlay(
            VStack {
                ZStack {
                    Image("drop")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 100 * rippleScale, height: 100 * rippleScale)
                       // .position(x:ripplePlace,y:0)
                        //.opacity(0.5)
                        .opacity(1.0*rippleOpacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                SoundManager.instance.playRhythm()
                                rippleScale = 0
                                rippleOpacity = 1.0
                                withAnimation(.easeOut(duration: 3.0)) {
                                    rippleScale = 30
                                    rippleOpacity = 0.0
                                }
                            }
                        }
                    Text("あ")
                        .font(Font.custom("HiraMinProN-W3", size: 130))
                        .foregroundColor(Color(hex: 0x303030))
                        .opacity(0.80)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true
                }
            }
            )
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
