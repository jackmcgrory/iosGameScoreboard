import SwiftUI

class ChaseGameModel: ObservableObject {
    @Published var buttonPosition = CGPoint(x: 100, y: 100)  // Initial position
    @Published var score = 0  // Player's score
    @Published var countdown = 30  // Countdown timer
    private var direction: CGVector = CGVector(dx: 1, dy: 1)  // Direction of movement
    private var speed: CGFloat = 2  // Initial speed
    private var moveTimer: Timer?
    private var countdownTimer: Timer?
    
    private let buttonWidth: CGFloat = 100  // Button width
    private let buttonHeight: CGFloat = 80  // Button height

    // Start both the button movement and countdown timers
    func startMoving() {
        startButtonMovement()
        startCountdown()
    }

    private func startButtonMovement() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.moveButton()
        }
    }
    
    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                self.stopMoving()  // Stop the game when time runs out
            }
        }
    }

    // Move button to a new position based on speed and direction
    func moveButton() {
        // Update position based on speed and direction
        buttonPosition = CGPoint(x: buttonPosition.x + direction.dx * speed, y: buttonPosition.y + direction.dy * speed)

        // Get screen bounds
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // Adjust boundary logic to account for the button's width and height
        if buttonPosition.x <= 0 || buttonPosition.x + buttonWidth >= screenWidth {
            direction.dx = -direction.dx
        }
        if buttonPosition.y <= 0 || buttonPosition.y + buttonHeight >= screenHeight {
            direction.dy = -direction.dy
        }
    }

    // Increment score and increase speed
    func buttonTapped() {
        print("button clicked score +1 of \(score)")
        score += 1
        increaseSpeed()
    }

    // Increase speed each time the button is tapped
    private func increaseSpeed() {
        speed += 1.5  // Increase speed by 1.5 each time
    }

    // Stop both the button movement and countdown timers
    func stopMoving() {
        moveTimer?.invalidate()
        moveTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}
