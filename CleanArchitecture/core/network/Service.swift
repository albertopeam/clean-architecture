//
//  Service.swift
//  CleanArchitecture
//
//  Created by Alberto on 30/05/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import Foundation

protocol Service {
    var method: Method { get }
    var endpoint: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var body: [String: String]? { get }
    var headers: [String: String]? { get }
    var urlRequest: URLRequest { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeInterval: TimeInterval { get }
}

enum Method: String {
    case get, post, put, delete, head
}

extension Service {
    var urlRequest: URLRequest {
        var components = URLComponents(string: endpoint)!
        components.path = path
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!, cachePolicy: cachePolicy, timeoutInterval: timeInterval)
        //TODO: codable or dict
        //request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue.uppercased()
        return request
    }
    var cachePolicy: URLRequest.CachePolicy { return URLRequest.CachePolicy.useProtocolCachePolicy }
    var timeInterval: TimeInterval { return 60 }
    var queryItems: [String : String]? { return nil }
    //TODO: codable or dict
    var body: [String : String]? { return nil }
    var headers: [String: String]? { return nil }
}


//let url = "https://api.openweathermap.org/data/2.5/weather?q={{city}}&appid=\(apiKey)"

protocol OpenWeatherService: Service {}

extension OpenWeatherService {
    var endpoint: String { return "https://api.openweathermap.org" }
}

struct WeatherService: OpenWeatherService {

    private let city: String
    
    init(city: String) {
        self.city = city
    }
    
    var method: Method = .get
    var path: String = "/data/2.5/weather"
    var queryItems: [URLQueryItem]? {
        return [URLQueryItem(name: "q", value: city), URLQueryItem(name: "appid", value: Constants.openWeatherApiKey)]
    }

}

enum HTTP {
    
    class Client {
        
        private let urlSession: URLSession
        private let dispatch: DispatchSemaphore
        private var task: URLSessionDataTask?
        
        init(urlSession: URLSession = .shared,
             dispatch: DispatchSemaphore = DispatchSemaphore(value: 0)) {
            self.urlSession = urlSession
            self.dispatch = dispatch
        }
        
        func send(request: URLRequest) -> Swift.Result<Response, Swift.Error> {
            var data: Data?
            var response: HTTPURLResponse?
            var error: Swift.Error?
            task?.cancel()
            task = urlSession.dataTask(with: request) { [weak self] (dat, res, err) in
                guard let self = self else { return }
                data = dat
                response = res as? HTTPURLResponse
                error = err
                self.dispatch.signal()                
            }
            task?.resume()
            //dispatch.wait()
            //TODO: check if works, now cities are unsorted
            _ = dispatch.wait(timeout: .now() + 60)
            if let urlResponse = response, urlResponse.statusCode >= 200 && urlResponse.statusCode <= 299, let data = data {
                return .success(Response(response: urlResponse, data: data))
            } else if let error = error {
                return .failure(error)
            } else {
                return .failure(Error.canceled)
            }
        }
        
    }
    
    struct Response {
        let response: HTTPURLResponse
        let data: Data
    }
    
    enum Error: Swift.Error {
        case canceled
    }

}




//TODO: enum en vez de struct, no creo
//TODO: retrier, basic, bearer, oauth
//NSOperation chain...

//BLOCKING VERSION
import UIKit

class Background {
    
    private let queue: DispatchQueue
    private let mainQueue: DispatchQueue
    
    init(queue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated),
         mainQueue: DispatchQueue = DispatchQueue.main) {
        self.queue = queue
        self.mainQueue = mainQueue
    }
    
    func execute<O>(_ execute: @escaping @autoclosure () -> O, respond: @escaping (O) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let tmp = execute()
            self.mainQueue.async {
                respond(tmp)
            }
        }
    }
}

class Presenter {
    
    private let background: Background
    
    init(background: Background = Background()) {
        self.background = background
    }
    
    func performOperation() {
        let operation = SomeOperation()
        background.execute(operation.job(()), respond: resulting(result:))
    }
    
    private func resulting(result: String) {
        print("Result: \(result)")
    }
}

class SomeOperation {
    func job(_ input: Void) -> String {
        return "resulting..."
    }
}

// ASYNC MODEL
class OneViewController: UIViewController {
    
    private let threading: Threading
    private let presenter: OnePresenter
    private let tableView: UITableView = UITableView.mold
    private var dataSource: ArrayDataSource<InstantWeather> = ArrayDataSource()
    
    init(threading: Threading = Threading(),
         presenter: OnePresenter = OnePresenter()) {
        self.threading = threading
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.view = self
        self.dataSource = ArrayDataSource(cellForRow: { item in
            var cell: UITableViewCell
            if let reuseCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") {
                cell = reuseCell
            } else {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
            }
            cell.textLabel?.text = item.name
            return cell
        })
        tableView.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addStickyView(tableView)
        //TODO: forcing multiple requests...
        threading.request(self.presenter.load(city: "A Coruña"))
        threading.request(self.presenter.load(city: "Vigo"))
    }
    
    func update(_ model: OneModel) {
        threading.render { [weak self] in
            guard let self = self else { return }
            switch model {
            case .loading(let message):
                self.tableView.refreshControl?.beginRefreshing()
                //TODO: no pinta loading...
                //TODO: no pinta loading...
                //TODO: no pinta loading...
                print("LOADING \(message)")
            case .error(let error):
                self.tableView.refreshControl?.endRefreshing()
                print("ERROR \(error)")
            case .success(let data):
                self.tableView.refreshControl?.endRefreshing()
                self.dataSource.items = [data]
                self.tableView.reloadData()
                print("SUCCESS \(data)")
            }
        }
    }
    
}

enum OneModel {
    case loading(message: String)
    case error(error: String)
    case success(weather: InstantWeather)
}

class OnePresenter {
    
    weak var view: OneViewController?
    private let oneUseCase: OneUseCase
    
    init(oneUseCase: OneUseCase = OneUseCase()) {
        self.oneUseCase = oneUseCase
    }
    
    func load(city: String) {
        view?.update(OneModel.loading(message: "Loading..."))
        do {
            let result = try oneUseCase.weather(for: city)
            view?.update(OneModel.success(weather: result))
        } catch {
            view?.update(OneModel.error(error: error.localizedDescription))
        }
    }
    
}

class OneUseCase {
    
    enum Error: Swift.Error {
        case error
    }
    
    private let weatherForCityService: WeatherForCityService
    
    init(weatherForCityService: WeatherForCityService = WeatherForCityService()) {
        self.weatherForCityService = weatherForCityService
    }
    
    func weather(for city: String) throws -> InstantWeather {
        do {
            return try weatherForCityService.call(city: city)
        } catch {
            throw Error.error
        }
    }
    
}

//probar si chola y luego cambiar a predicciones a ver si va....
class WeatherForCityService {
    
    private let httpClient: HTTP.Client
    
    init(httpClient: HTTP.Client = HTTP.Client()) {
        self.httpClient = httpClient
    }
    
    func call(city: String) throws -> InstantWeather {
        let service = WeatherService(city: city)
        switch httpClient.send(request: service.urlRequest) {
        case .success(let data):
            let cr: CloudWeatherResponse = try JSONDecoder().decode(CloudWeatherResponse.self, from: data.data)
            return InstantWeather(name: cr.name,
                                  description: cr.weather[0].description,
                                  icon: cr.weather[0].icon,
                                  temp: cr.main.temp,
                                  pressure: cr.main.pressure,
                                  humidity: cr.main.humidity,
                                  windSpeed: cr.wind.speed,
                                  windDegrees: cr.wind.deg,
                                  datetime: cr.dt)
        case .failure(let error):
            throw error
        }
    }
}

//TODO: change name
class Threading {
    
    private let requestQueue: DispatchQueue
    private let renderQueue: DispatchQueue
    
    init(requestQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility),
         renderQueue: DispatchQueue = DispatchQueue.main) {
        self.requestQueue = requestQueue
        self.renderQueue = renderQueue
    }
    
    func request(_ function: @escaping @autoclosure () -> ()) {
        requestQueue.async { function() }
    }
    
    func render(_ function: @escaping () -> ()) {
        renderQueue.async { function() }
    }
    
}




//NSOPERATION VERSION
//https://ioscoachfrank.com/chaining-nsoperations.html
//https://nickharris.wordpress.com/2016/02/03/retain-cycle-with-nsoperation-dependencies-help-wanted/
//class OperationQueue {
//    ???
//    var operations = [CAOperation]()
//
//    func execute() {
//
//    }
//}
//
//class CAOperation<I, O>: Operation {
//
//    var input: I?
//    var outptut: O?
//
//
//}

//TODO: adapter delegate pattern!!!
class ArrayDataSource<T>: NSObject, UITableViewDataSource {
    
    var items: [T]
    private let cellForRow: (_ item: T) -> UITableViewCell
    
    init(items: [T] = [T](),
         cellForRow: @escaping (_ item: T) -> UITableViewCell = { _ in fatalError() }) {
        self.items = items
        self.cellForRow = cellForRow
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRow(items[indexPath.row])
    }
    
}

//TODO: Decorator
//TODO: renewal mechanism
//TODO: Router: push/modal/set emvbed in vc
