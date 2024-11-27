import SwiftUI

struct ChaseGameView: View {
    @StateObject private var game = ChaseGameModel()
    @State private var screenSize = CGSize.zero  // Screen size to calculate movement bounds
    @State private var timer: Timer?            // Timer to move the button periodically

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Score Display
                VStack {
                    Text("Score: \(game.score)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    Spacer()
                }
                
                // Moving Button
                Button(action: {
                    game.buttonTapped()
                    moveButtonAfterTap(size: geometry.size)
                }) {
                    Text("Tap Me!")
                        .font(.headline)
                        .padding()
                        .frame(width: 100, height: 80)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .position(game.buttonPosition) 
                .onAppear {
                    screenSize = geometry.size
                    startGame()
                }
            }
        }
    }

    // Moves the button immediately after a tap
    private func moveButtonAfterTap(size: CGSize) {
        game.moveButton(screenSize: size)
        restartTimer(size: size)
    }
    
    // Start the game timer
    private func startGame() {
        guard timer == nil else { return }
        restartTimer(size: screenSize)
    }

    // Restart timer to move the button faster
    private func restartTimer(size: CGSize) {
        timer?.invalidate()  // Stop the old timer
        timer = Timer.scheduledTimer(withTimeInterval: game.getSpeed(), repeats: true) { _ in
            game.moveButton(screenSize: size)
        }
    }
}


#Preview {
    ChaseGameView()
}
