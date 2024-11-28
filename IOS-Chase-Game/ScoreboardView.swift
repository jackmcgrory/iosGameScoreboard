import SwiftUI

struct ScoreboardView: View {
    var onRestart: () -> Void
    var onReturnToMenu: () -> Void
    var currentName: String

    var scores: [Score] = DatabaseHelper.shared.fetchScores()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Title for the scoreboard
                Text("Scoreboard")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                // Display scores in a list
                List {
                    ForEach(scores, id: \.id) { score in
                        HStack {
                            // Animate the current player's name
                            Text(score.name)
                                .foregroundColor(score.name == currentName ? .red : .black)
                                .font(.title2)
                            
                            Spacer()
                            
                            Text("\(score.score)")
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                HStack {
                    // Try Again Button
                    Button(action: {
                        onRestart()
                    }) {
                        Text("Try Again")
                            .font(.title2)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // Return to Menu Button
                    Button(action: {
                        onReturnToMenu()
                    }) {
                        Text("Return to Menu")
                            .font(.title2)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
}

