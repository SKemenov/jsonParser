//
//  ViewController.swift
//  jsonParser
//
//  Created by Sergey Kemenov on 23.05.2023.
//

import UIKit
enum NetworkError: Error {
	case codeError
}



enum CodingKeys: CodingKey {
	case name, poster, rating, limit, docs, total, page, pages, url, preeviewUrl, await, filmCritics, imdb, kp
}

struct kpHD: Codable {
	//	let limit: Int
	let docs: [Kinopoisk]
	//	let total: Int
	//	let page: Int
	//	let pages: Int
}

struct Kinopoisk: Codable {
let rating: [String: String]
	let poster: [String: String]
//	let rating: [Rating]
//	let poster: [Poster]
	//	var posterUrl: String {
	//		poster["url"]!
	//	}
}

struct Rating: Codable {
//	let await: String
//	let filmCritics: String
	let imdb: String
//	let kp: String
//	let russianFilmCritics: String
}

struct Poster: Codable {
	let url: String
	let previewUrl: String
}

class ViewController: UIViewController {



	func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
		var request = URLRequest(url: url)
		//		request.setValue("application/json", forHTTPHeaderField: "accept")
		request.setValue("3FWVXVZ-KJGMHZS-P95YZS7-E2DKHQJ", forHTTPHeaderField: "X-API-KEY")

		print("url: ", url)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			// error return check
			if let error {
				print("error request data")
				return }

			// unsuccess response code return check
			if let response = response as? HTTPURLResponse,
			   response.statusCode < 200 || response.statusCode >= 300 {
				return
			}

			//happy path
			guard let data else { return }
			print("Have data from fetch()")
			handler(.success(data))
		}
		task.resume()
	}

	func loadMovies(handler: @escaping (Result<kpHD, Error>) -> Void) {
//    guard let url = URL(string: "https://api.kinopoisk.dev/v1.3/movie?selectFields=name+rating+poster&page=1&limit=10&typeNumber=1&top250=%21null") else { return }
    guard let url = URL(string: "https://api.kinopoisk.dev/v1.3/movie?selectFields=rating.imdb+poster.url&page=1&limit=10&typeNumber=1&top250=%21null") else { return
    }
		fetch(url: url) { result in
			switch result {
				case .success(let data):
					print("loadMovies run case succeess")
					do {
            print("data: ", data)
						print("try to serialization JSON")
//            let jsonString = try JSONStr
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
						print("json: ", json)
						guard let json else { return }
//						print("json! - ", json)
            print()
//						let jsonName = json["name"]
//						print(jsonName)
            let jsonDocs = json["docs"]
            guard let jsonDocsDictionary = jsonDocs as [String: String] ?? [:] else { return }
            print(jsonDocsDictionary)
            let jsonRating = jsonDocsDictionary["poster"]
						print(jsonRating)
						let jsonPoster = json["url"]
						print(jsonPoster)
//						let mostPopularMovies = kpHD(docs: [Kinopoisk(name: json["name"], rating: json["rating": "imdb"], poster: json["poster"])])
						print("try to Decode JSON")

						let mostPopularMovies = try JSONDecoder().decode(kpHD.self, from: data)

						print("mostPopularMovies: ", mostPopularMovies)
						//						let mostPopularMovies = try JSONDecoder().decode(kpHD.self, from: data)
						handler(.success(mostPopularMovies))
						print("mostPopularMovies: ", mostPopularMovies)
					}
					catch {
						print("can't do case success")
						handler(.failure(error))
					}
				case .failure(let error):
					handler(.failure(error))
					print(error)
			}
		}
	}
  var movies: [kpHD] = []
	//	print(movies)

	//	 func printMovieUrl() {
	//		for movie in movies {
	//			print("movie.posterUrl ", movie.posterUrl)
	//		}
	//	}

	override func viewDidLoad() {
		super.viewDidLoad()

		//		let movies = try JSONDecoder().decode(kpHD.self, from: data)
print("run loadMovies from viewDidLoad")
		loadMovies { [weak self] result in

			guard let self = self else {
				print("error run loadMovies from viewDidLoad")
return }
			switch result {
				case .success(let mostPopularMovies):
					print("run success loadMovies from viewDidLoad")

					print(mostPopularMovies)
//					movies = mostPopularMovies.docs
					print("self.movies ", movies)
				case .failure:
					print("run failure loadMovies from viewDidLoad")

					return
			}

		}

		//		printMovieUrl()
		//		print(movies)
	}

}

