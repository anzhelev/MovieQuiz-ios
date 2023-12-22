//
//  Movie.swift
//  MovieQuiz
//
//  Created by Andrey Zhelev on 22.12.2023.
//

struct Actor: Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}
struct Movie: Codable {
    let id: String
    let title: String
    let year: String
    let image: String
    let releaseDate: String
    let runtimeMins: String
    let directors: String
    let actorList: [Actor]
}


