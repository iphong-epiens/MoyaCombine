//
//  Joke.swift
//  MoyaTestCase
//
//  Created by Inpyo Hong on 2021/08/30.
//

import Foundation

struct JokeReponse: Decodable {
  let type: String
  let value: Joke
}

struct Joke: Decodable {
  let id: Int
  let joke: String
  let categories: [String]
}
