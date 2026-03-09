//
//  ContentView.swift
//  Dinammo
//
//  Created by Екатерина Алейник on 5.03.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Статус бар
                        StatusBarView(
                            isConnected: networkManager.teamData != nil,
                            certValid: networkManager.serverCertValid,
                            sslError: networkManager.sslError
                        )
                        
                        if networkManager.isLoading {
                            LoadingView()
                        } else if networkManager.sslError {
                            SSLErrorView(retry: {
                                networkManager.fetchData()
                            })
                        } else if let error = networkManager.errorMessage {
                            ErrorView(message: error, retry: {
                                networkManager.fetchData()
                            })
                        } else if let data = networkManager.teamData {
                            // Шапка команды
                            TeamHeaderView(teamData: data)
                            
                            // Статистика сезона
                            SeasonStatsView(stats: data.season_stats)
                            
                            // Лучшие бомбардиры
                            TopScorersView(scorers: data.top_scorers)
                            
                            // Последние игры
                            RecentGamesView(games: data.recent_games)
                            
                            // Информация о сервере
                            ServerInfoView(certValid: networkManager.serverCertValid)
                        } else {
                            EmptyStateView(load: {
                                networkManager.fetchData()
                            })
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("ХК Динамо Минск")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        networkManager.fetchData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(networkManager.isLoading)
                }
            }
        }
        .onAppear {
            networkManager.fetchData()
        }
    }
}

// MARK: - Status Bar
struct StatusBarView: View {
    let isConnected: Bool
    let certValid: Bool
    let sslError: Bool
    
    var body: some View {
        HStack {
            // Индикатор подключения
            HStack(spacing: 6) {
                Circle()
                    .fill(isConnected ? Color.green : (sslError ? Color.red : Color.gray))
                    .frame(width: 8, height: 8)
                Text(isConnected ? "Подключено" : (sslError ? "Ошибка SSL" : "Нет данных"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Статус SSL
            if sslError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.caption)
                    Text("SSL PINNING ERROR")
                        .font(.caption)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            } else if certValid {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.caption)
                    Text("SSL PINNING OK")
                        .font(.caption)
                }
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Загрузка данных...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - SSL Error View
struct SSLErrorView: View {
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Ошибка SSL Pinning")
                .font(.headline)
                .foregroundColor(.red)
            
            Text("Сертификат сервера изменен")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("Запустите сервер с валидным сертификатом")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Повторить", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Ошибка")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Повторить", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let load: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sportscourt")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("ХК Динамо Минск")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Нажмите для загрузки статистики")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button("Загрузить", action: load)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Team Header View
struct TeamHeaderView: View {
    let teamData: HockeyTeamData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("dinamo1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(teamData.team)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("КХЛ • Западная конференция")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                Text("Обновлено: \(formatDate(teamData.last_update))")
                    .font(.caption)
                Spacer()
            }
            .foregroundColor(.gray)
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .short
            outputFormatter.locale = Locale(identifier: "ru_RU")
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Season Stats View
struct SeasonStatsView: View {
    let stats: SeasonStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок с очками
            HStack {
                Label("Статистика сезона", systemImage: "chart.bar")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Очки:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(stats.points)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Сетка статистики
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatItem(title: "Игры", value: "\(stats.games_played)", color: .gray)
                StatItem(title: "Победы", value: "\(stats.wins)", color: .green)
                StatItem(title: "Поражения", value: "\(stats.losses)", color: .red)
                StatItem(title: "Забито", value: "\(stats.goals_scored)", color: .blue)
                StatItem(title: "Пропущено", value: "\(stats.goals_conceded)", color: .orange)
                StatItem(title: "ОТ/Бул", value: "\(stats.draws)", color: .purple)
            }
            
            // Разница шайб
            let difference = stats.goals_scored - stats.goals_conceded
            HStack {
                Text("Разница шайб:")
                    .font(.subheadline)
                Spacer()
                Text("\(difference >= 0 ? "+" : "")\(difference)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(difference >= 0 ? .green : .red)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Top Scorers View
struct TopScorersView: View {
    let scorers: [Scorer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Лучшие бомбардиры", systemImage: "person.3")
                .font(.headline)
                .foregroundColor(.blue)
            
            if scorers.isEmpty {
                Text("Нет данных о бомбардирах")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(scorers.enumerated()), id: \.element.id) { index, scorer in
                    HStack {
                        if index == 0 {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 25)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(width: 25, alignment: .leading)
                        }
                        
                        Text(scorer.name)
                            .font(.body)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("\(scorer.goals)")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                            Text("+")
                                .foregroundColor(.gray)
                            Text("\(scorer.assists)")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                            Text("=\(scorer.points)")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if index < scorers.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Recent Games View (исправлено)
struct RecentGamesView: View {
    let games: [GameResult]  // Изменено с game на games
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Последние игры", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.blue)
            
            if games.isEmpty {
                Text("Нет данных о последних играх")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(games) { game in  // Проходим по массиву games
                    GameRowView(game: game)
                    if game.id != games.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Game Row View (добавлено)
struct GameRowView: View {
    let game: GameResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Дата и результат
            HStack {
                Text(game.date)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(game.resultText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(game.resultColor.opacity(0.2))
                    .foregroundColor(game.resultColor)
                    .cornerRadius(4)
            }
            
            // Соперник и счет
            HStack {
                Text(game.opponent)
                    .font(.headline)
                
                Spacer()
                
                if game.isOvertime {
                    Text("\(game.goals_for) : \(game.goals_against) ОТ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(game.resultColor)
                } else {
                    Text("\(game.goals_for) : \(game.goals_against)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(game.resultColor)
                }
            }
            
            // Детали игры
            HStack {
                Label("\(game.shots) бросков", systemImage: "target")
                Spacer()
                Label("\(Int(game.faceoffs_win_percentage))% вброс.", systemImage: "figure.hockey")
                Spacer()
                Label("\(game.penalty_minutes)' штраф", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Server Info View
struct ServerInfoView: View {
    let certValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "server.rack")
                .foregroundColor(.gray)
            Text("Сервер: \(getServerAddress())")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Image(systemName: certValid ? "checkmark.seal.fill" : "exclamationmark.seal.fill")
                .foregroundColor(certValid ? .green : .orange)
                .font(.caption)
            
            Text(certValid ? "Валидный" : "Изменен")
                .font(.caption)
                .foregroundColor(certValid ? .green : .orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func getServerAddress() -> String {
        #if targetEnvironment(simulator)
        return "localhost:8443"
        #else
        return "192.168.100.0:8443" // Change the IP address to yours
        #endif
    }
}
