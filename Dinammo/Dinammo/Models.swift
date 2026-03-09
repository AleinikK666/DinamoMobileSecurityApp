//
//  Models.swift
//  Dinammo
//
//  Created by Екатерина Алейник on 5.03.26.
//

import Foundation
import SwiftUI

struct HockeyTeamData: Codable {
    let team: String
    let last_update: String
    let recent_games: [GameResult]
    let season_stats: SeasonStats
    let top_scorers: [Scorer]
    
    // Вычисляемые свойства для удобства использования в UI
    var lastUpdate: String { last_update }
    var recentGames: [GameResult] { recent_games }
    var seasonStats: SeasonStats { season_stats }
}

struct GameResult: Codable, Identifiable {
    let id = UUID()
    let date: String
    let opponent: String
    let goals_for: Int
    let goals_against: Int
    let result: String
    let shots: Int
    let faceoffs_win_percentage: Double
    let penalty_minutes: Int
    
    // Вычисляемые свойства
    var goalsFor: Int { goals_for }
    var goalsAgainst: Int { goals_against }
    var faceoffsWinPercentage: Double { faceoffs_win_percentage }
    var penaltyMinutes: Int { penalty_minutes }
    
    var resultText: String {
        switch result {
        case "win": return "ПОБЕДА"
        case "loss": return "ПОРАЖЕНИЕ"
        default: return "ОТ/БУЛ"
        }
    }

    var resultColor: Color {
        switch result {
        case "win": return .green
        case "loss": return .red
        default: return .purple
        }
    }
    var isOvertime: Bool {
        return result == "ot_win" || result == "ot_loss" || result == "draw"
    }
}

struct SeasonStats: Codable {
    let games_played: Int
    let wins: Int
    let losses: Int
    let draws: Int
    let goals_scored: Int
    let goals_conceded: Int
    let points: Int
    
    // Вычисляемые свойства
    var gamesPlayed: Int { games_played }
    var goalsScored: Int { goals_scored }
    var goalsConceded: Int { goals_conceded }
}

struct Scorer: Codable, Identifiable {
    let id = UUID()
    let name: String
    let goals: Int
    let assists: Int
    
    var points: Int {
        goals + assists
    }
}

struct CertStatus: Codable {
    let certificate: String
    let valid: Bool
}
