import Foundation
import SQLite3

class DatabaseHelper {
    
    static let shared = DatabaseHelper() // Singleton instance
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTable() // Ensure table is created when the app runs
    }
    
    // Open the SQLite database
    private func openDatabase() {
        // Get the path to the database file
        let path = getDatabasePath()
        
        // Open the database, if it doesn't exist it will be created
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Successfully opened database at \(path)")
        }
    }
    
    // Get the path to the SQLite database
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let databaseURL = documentDirectory.appendingPathComponent("database.sqlite")
        return databaseURL.path
    }
    
    // Create the Scoreboard table if it doesn't exist
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Scoreboard (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            score INTEGER
        );
        """
        
        // Prepare the query
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Scoreboard table created successfully.")
            } else {
                print("Error creating table: \(String(cString: sqlite3_errmsg(db)))")
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        // Finalize the statement
        sqlite3_finalize(stmt)
    }
    
    // Insert or update a user's score
    func insertScore(name: String, score: Int) {
        // Check if the user already exists
        let checkQuery = "SELECT score FROM Scoreboard WHERE name = ?;"
        var stmt: OpaquePointer?
        
        // Prepare the statement
        if sqlite3_prepare_v2(db, checkQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, name, -1, nil)  // Bind the user name
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                // User exists, check if the current score is higher
                let existingScore = sqlite3_column_int(stmt, 0)
                
                if score > Int(existingScore) {
                    // If the new score is higher, update the score
                    let updateQuery = "UPDATE Scoreboard SET score = ? WHERE name = ?;"
                    var updateStmt: OpaquePointer?
                    
                    if sqlite3_prepare_v2(db, updateQuery, -1, &updateStmt, nil) == SQLITE_OK {
                        sqlite3_bind_int(updateStmt, 1, Int32(score))  // Bind the new score
                        sqlite3_bind_text(updateStmt, 2, name, -1, nil)  // Bind the user name
                        
                        if sqlite3_step(updateStmt) == SQLITE_DONE {
                            print("Updated score for \(name) to \(score).")
                        } else {
                            print("Error updating score: \(String(cString: sqlite3_errmsg(db)))")
                        }
                        sqlite3_finalize(updateStmt)
                    }
                } else {
                    print("\(name) already has a higher or equal score.")
                }
            } else {
                // User does not exist, insert new score
                let insertQuery = "INSERT INTO Scoreboard (name, score) VALUES (?, ?);"
                
                var insertStmt: OpaquePointer?
                
                if sqlite3_prepare_v2(db, insertQuery, -1, &insertStmt, nil) == SQLITE_OK {
                    sqlite3_bind_text(insertStmt, 1, name, -1, nil)  // Bind name
                    sqlite3_bind_int(insertStmt, 2, Int32(score))  // Bind score
                    
                    if sqlite3_step(insertStmt) == SQLITE_DONE {
                        print("\(name): \(score) inserted successfully.")
                    } else {
                        let errorMessage = String(cString: sqlite3_errmsg(db))
                        print("Error inserting score: \(errorMessage)")
                    }
                    sqlite3_finalize(insertStmt)
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing check statement: \(errorMessage)")
        }
        
        sqlite3_finalize(stmt)
    }

    // Fetch all users from the Scoreboard table
    func fetchScores() -> [Score] {
        var scores = [Score]()
        let fetchQuery = "SELECT * FROM Scoreboard ORDER BY score DESC;"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, fetchQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                let score = sqlite3_column_int(stmt, 2)
                
                let userScore = Score(id: Int(id), name: name, score: Int(score))
                scores.append(userScore)
            }
        } else {
            print("Error fetching scores: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(stmt)
        return scores
    }
    
    // Close the database connection
    deinit {
        sqlite3_close(db)
    }
}
