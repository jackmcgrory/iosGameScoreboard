import SwiftUI

struct ChaseGameView: View {
    @StateObject private var game = ChaseGameModel()
    @State private var screenSize = CGSize.zero
    @State private var playerName = ""  // Player's name input
    @State private var gameStarted = false  // Flag to start the game
    @State private var gameEnded = false  // Flag to end game
    @State private var scores: [Score] = []  // List of scores
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Main content based on whether the game has started or not
            if gameStarted && !gameEnded {
                GeometryReader { geometry in
                    VStack {
                        // Add colored border around the screen
                        ZStack {
                            // Border container
                            Rectangle()
                                .strokeBorder(Color.blue, lineWidth: 10) // Change color and width as needed
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            VStack{
                                // Countdown Timer
                                Text("Time: \(game.countdown)")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .padding()
                                
                                Spacer()
                                
                                // Score Display
                                Text("Score: \(game.score)")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            
                            Spacer()
                            
                            // Moving Button inside the border
                            Button(action: {
                                game.buttonTapped()  // Tap to increase score and speed
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
                            }
                        }
                    }
                }
                .onChange(of: game.countdown) { newValue in
                    if newValue == 0 {
                        endGame()  // End the game when time runs out
                    }
                }
            } else if gameEnded {
                // Scoreboard screen when game ends
                ScoreboardView(onRestart: restartGame, onReturnToMenu: returnToMenu, currentName: playerName)
            } else {
                // Name input screen
                VStack {
                    Text("Enter Your Name:")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    
                    TextField("Your Name", text: $playerName)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding()
                    
                    Button(action: {
                        startGame()
                    }) {
                        Text("Start Game")
                            .font(.headline)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }

    // Start the game by hiding the name input screen and starting the timer
    private func startGame() {
        gameStarted = true
        game.startMoving()
    }

    // End the game and show the scoreboard
    private func endGame() {
        DatabaseHelper.shared.insertScore(name: playerName, score: game.score)
        gameEnded = true
    }

    // Restart the game with the same name
    private func restartGame() {
        game.score = 0
        game.countdown = 30
        gameStarted = true
        gameEnded = false
        game.startMoving()
    }

    // Return to the name entry screen
    private func returnToMenu() {
        game.score = 0
        game.countdown = 30
        gameStarted = false
        gameEnded = false
    }
}

#Preview {
    ChaseGameView()
}
