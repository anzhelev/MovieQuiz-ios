protocol StatisticService {
    func store(game score: GameRecord)
    var totalAccuracy: Double {get}
    var gamesCount: Int {get}
    var bestGame: GameRecord {get}
    var statistics: String {get}
}
