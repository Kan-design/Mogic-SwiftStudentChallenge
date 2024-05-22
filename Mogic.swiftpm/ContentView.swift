import SwiftUI
import AVFoundation
import Foundation

struct ContentView: View {
    @State var positions: [CGPoint] = []
    @State var numbers: [Int] = []
    @State var textSizes: [Double] = []

    @State private var angle: Double = 300
    @State private var lastAngle: Double = 0
    @State private var length : Double = 400
    @State private var angle2: Double = 200
    @State private var lastAngle2: Double = 0
    @State private var dialPosition: CGPoint = .zero
    @State private var isDialPressed:Bool = false
    
    @State private var rippleScale: Double = 1.0
    @State private var rippleOpacity: Double = 0.0
    @State private var ripplePlace:Double = 100
    
    var sortedItems: [(position: CGPoint, number: Int)] {
        zip(positions, numbers).sorted { $0.0.y < $1.0.y }
    }
    private func deleteItemAt(_ index: Int) {
        positions[index] = .zero
        numbers[index] = 50
        textSizes[index] = 0
    }
    func playHiraganaDelay(hiraganaNum: Int, delayInSeconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            SoundManager.instance.playSound(hiraganaSound: hiraganaNum)
        }
    }
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            Color(hex: 0xE0E5EC)
                .ignoresSafeArea()
                .onAppear {
                    self.dialPosition = CGPoint(x: geometry.size.width-20, y: geometry.size.height-20)
                }
                .onChange(of: geometry.size) {
                    self.dialPosition = CGPoint(x: geometry.size.width-20, y: geometry.size.height-20)
                }
            
            Image("drop")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: 100 * rippleScale, height: 100 * rippleScale)
                .position(x:ripplePlace,y:0)
                .opacity(rippleOpacity)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
                        print("width: \(geometry.size.width), height: \(geometry.size.height)")
                        rippleScale = 0
                        rippleOpacity = 1.0
                        ripplePlace = Double.random(in: 0..<geometry.size.width)
                        withAnimation(.easeOut(duration: 3.0)) {
                            rippleScale = 20
                            rippleOpacity = 0.0
                        }
                    }
                }
            
            ForEach(positions.indices, id: \.self) { index in
                DraggableView(position: $positions[index], number: numbers[index], textSize: $textSizes[index]) {
                    self.deleteItemAt(index)
                }
            }
            
                Image("DialOutside")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: length, height: length)
                    .rotationEffect(.degrees(Double(self.angle)), anchor: UnitPoint(x: 0.5, y: 0.5))
                    .onAppear {
                        withAnimation{
                            self.angle = 324
                        }
                    }
                    .gesture(DragGesture()
                        .onChanged{ v in
                            var theta = (atan2(v.location.x - self.length / 2, self.length / 2 - v.location.y) - atan2(v.startLocation.x - self.length / 2, self.length / 2 - v.startLocation.y)) * 180 / .pi
                            if (theta < 0) { theta += 360 }
                            self.angle = theta + self.lastAngle  
                        }
                        .onEnded { v in
                            self.lastAngle = self.angle
                            withAnimation {
                                self.angle = Double(round(self.angle/36)*36)
                            }
                        }
                    )
                    .position(dialPosition)
                
                Image("DialShadow")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: length*0.6*1.18, height: length*0.6*1.18)
                    .scaleEffect(isDialPressed ? 0.96 : 1)
                    .position(dialPosition)
                
                Image("DialInside")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: length*0.6, height: length*0.6)
                    .rotationEffect(.degrees(Double(self.angle2)), anchor: UnitPoint(x: 0.5, y: 0.5))
                    .scaleEffect(isDialPressed ? 0.96 : 1)
                    .onAppear {
                        withAnimation{
                            self.angle2 = 324
                        }
                    }
                    .gesture(DragGesture()
                        .onChanged{ v in
                            var theta = (atan2(v.location.x - self.length*0.6 / 2, self.length*0.6 / 2 - v.location.y) - atan2(v.startLocation.x - self.length*0.6 / 2, self.length*0.6 / 2 - v.startLocation.y)) * 180 / .pi
                            if (theta < 0) { theta += 360 }
                            self.angle2 = theta + self.lastAngle2
                        }
                        .onEnded { v in
                            self.lastAngle2 = self.angle2
                            withAnimation {
                                self.angle2 = Double(round(self.angle2/36)*36)
                            }
                        }
                    )
                    .position(dialPosition)
                    .onTapGesture {
                        positions.append(CGPoint(x: Double.random(in: 0..<geometry.size.width), y: Double.random(in: 0..<geometry.size.height-200)))
                        let hiraganaNum = (Int(round(self.angle2/36+1))%10)*5+(Int(round(self.angle/36+1))%5)
                        numbers.append(hiraganaNum)
                        textSizes.append(Double.random(in: 150..<300))
                        SoundManager.instance.playSound(hiraganaSound: hiraganaNum)
                        isDialPressed.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            withAnimation {
                                isDialPressed.toggle()
                            }
                        }
                    }
                
                Image("DialSelector")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: length, height: length)
                    .opacity(0.5)//0.5未満Viewならタッチが透過する
                    .position(dialPosition)
            
        }//ZStack
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                print("numbers:\(numbers),positions:\(positions), textsizes:\(textSizes)")
                if sortedItems.count > 0 {
                    for i in 0..<sortedItems.count {
                        if sortedItems[i].number != 50 {
                            playHiraganaDelay(hiraganaNum: sortedItems[i].number, delayInSeconds: (sortedItems[sortedItems.count==1 ? 0: i].position.y)/260)
                        }
                    }
                }
                SoundManager.instance.playRhythm()
            }
        }
    }
}
}

let Hiragana = 
["あ", "い", "う", "え", "お", 
 "か", "き", "く", "け", "こ", 
 "さ", "し", "す", "せ", "そ", 
 "た", "ち", "つ", "て", "と", 
 "な", "に", "ぬ", "ね", "の", 
 "は", "ひ", "ふ", "へ", "ほ", 
 "ま", "み", "む", "め", "も", 
 "や", "い", "ゆ", "え", "よ", 
 "ら", "り", "る", "れ", "ろ", 
 "わ", "ゐ", "う", "ゑ", "を", ""]

struct DraggableView: View, Identifiable {
    var id = UUID()
    var number: Int
    var onDelete: () -> Void
    @Binding var position: CGPoint
    @State private var isPressed = true
    @GestureState private var longPressTap = false
    @Binding var textSize: Double 
    
    init(position: Binding<CGPoint>, number: Int, textSize: Binding<Double>, onDelete: @escaping () -> Void) {
        self._position = position
        self.number = number
        self._textSize = textSize
        self.onDelete = onDelete
    }
    var body: some View {
        ZStack {
            Text(Hiragana[number])
                .foregroundColor(Color(hex: 0x303030))
                .font(.custom("HiraMinProN-W3", size: textSize))
                .position(x: position.x, y: position.y)
                .opacity(isPressed ? 0.0 : 0.6)
                .scaleEffect(isPressed ? 0.96 : 1)
                .animation(.easeInOut)
                .onAppear {
                    self.isPressed.toggle()
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .updating($longPressTap) { value, state, _ in
                            state = value
                        }
                        .onEnded { _ in
                            print("ondelete")
                            self.isPressed.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.onDelete()
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            position = CGPoint(x: value.startLocation.x + value.translation.width, y: value.startLocation.y + value.translation.height)
                        }
                )
        }
    }
}
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }

class SoundManager {
    static let instance = SoundManager()
    var audioPlayer: AVAudioPlayer?
    static let shared = SoundManager()
    private var audioPlayers: [AVAudioPlayer] = []
    private init() {}
    func playSound(hiraganaSound: Int) {
        if let soundURL = Bundle.main.url(forResource: String(hiraganaSound), withExtension: "mp3") {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                audioPlayers.append(audioPlayer)
            } catch {
                print("Error playing sound: \(error)")
            }
        } else {
            print("Sound file not found")
        }
    }
    
    func playRhythm() {
        if let soundURL = Bundle.main.url(forResource: "waterdrop", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        } else {
            print("Sound file not found")
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
