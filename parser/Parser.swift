//
//  Parser.swift
//  parser
//
//  Created by Vladimir Anisimov on 27.07.2021.
//

import Foundation
import SwiftSoup

class Parser {
    
    enum Constant {
        static let maxElementInQuoteCount = 200
    }
    static var shared = Parser()

    func parseQuotes(tagName: String, lastPage: Int, completion:  @escaping ([Quotes]) -> ()) {
        var quotes = [Quotes]()
        let group = DispatchGroup()
        print("Start Parsing")
        for page in 1...lastPage {
            group.enter()
            guard let url = URL(string: "https://www.goodreads.com/quotes/tag/feminism?page=\(page)") else { return }
            htmlFor(url) { data in
                
                do {
                    guard let data = data else { return }
                    guard  let html = String(data: data, encoding: .utf8) else { return }
                    let doc: Document = try SwiftSoup.parse(html)
                    let htmlQuotesArray = try doc.select(".quoteText").array()
                    let separatedItems = try htmlQuotesArray
                        .map { try $0.text() }
                        .map { return $0.split(separator: "―") }
                        .filter { $0.count == 2 }
                        
                    let filteredItems = separatedItems
                        .filter { return $0[0].count <= Constant.maxElementInQuoteCount}
                        .filter { return !String($0[0]).isArabic}
                        .map { el -> [String] in
                            let quoteText = el[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let author = el[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            return [quoteText, author]
                        }
                        .map { el -> [String] in
                            var quoteText = el[0]
                            if quoteText.first == "“" && quoteText.last == "”" {
                                quoteText.removeFirst()
                                quoteText.removeLast()
                            }
                            
                            var author = el[1]
                            let separatedItemsAuthor =  author.split(separator: ",")
                            if !separatedItemsAuthor.isEmpty {
                                author = String(separatedItemsAuthor[0])
                            }
                            return [quoteText, author]
                        }
                    let quotesInPage = filteredItems
                        .map { Quotes(quote: $0[0], author: $0[1])}
                    
                    quotes.append(contentsOf: quotesInPage)
                    print( page.description + " parsing completed... ")
                    group.leave()
                    
                } catch {
                    group.leave()
                    print(error)
                }
            }
        }

        
        group.notify(queue: .main) {
            completion(quotes)
        }
        
    }
    
    
    private func htmlFor(_ url: URL, completion: @escaping (Data?) -> ()) {
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { data, response, error in
            completion(data)
        }
        task.resume()
    }
    
}

extension String {
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
}
