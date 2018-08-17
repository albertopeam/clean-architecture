# Clean Architecture

The intention of this repository is to show some of the more common practices when building a mobile app using clean architecture.

So, be carefull, this is a WORK IN PROGRESS...

## Table of Contents
1. [Before start](#before-start)
2. [What do you expect to see soon?](#what-do-you-expect-to-see-soon?)
3. [Architecture](#architecture)
4. [Patterns](#patterns)
    1. [Promises](#promises)
        * [Legacy](#swift:-Legacy)
        * [Serial](#swift:-Serial-work)
        * [Parallel](#swift:-Parallel-work)
    2. [MVVM](#mvvm)
        * [View-Model](#Swift:-Observer)
        * [Widget](#Swift:-Reusing-View-Model-in-TodayExtension)
5. [Testing](#testing)

## Before start
* iOS
    * Resolve Carthage dependencies. For more [info](https://github.com/Carthage/Carthage)
    ```
    carthage update --platform iOS
    ```
    * To run the project you should create a file called Constants with your own Google and OpenWeather Api Key. For more [Google info](https://developers.google.com/places/web-service/search), for more [Open weather info](https://openweathermap.org/appid)
    ```
        class Constants {
            static let googleApiKey = "add-your-own-key"
            static let openWeatherApiKey = "add-your-own-key"
        }
    ```

### App
* iOS:
    * app/places: shows a list of places near your current location
    * app/weather: shows the weather in a list of places.

### Testing
* iOS
    * The tests currently cover promises and places component  

<!---
## Project structure
* iOS folder -> Swift iOS project
--->
## What do you expect to see soon?
### Next
* iOS    
    * create a core module to show how to do it. The idea is avoid publishing internal dependencies
    * add architecture explanation, guidelines
    * example with promises all. rewrite promise once        
    * ViewModel to reduce complexity between view-presenter
    * ViewStateMachine for complex UIs
    * observer
    * UI testing    

## Architecture

### Packaging
Packaging is a very important feature in terms of how to structure our code in reusable components.

Kinds of architectures by packanging type:
* Layer

Widely know by the community, is one of the most used.

![Alt layer](art/LAYER.png)

| *PROS* | *CONS* | 
| :---         | :---           |
| Widely used, so probably most developers know how to use it | |
| Easy to understand the code that belongs to the same layer | Related code is splitted in layers so flows are not easy to follow |
| | Each layer should expose their entire API to the upward layer |
| |  |
* Feature

![Alt feature](art/FEATURE.png)

| *PROS* | *CONS* | 
| :---         | :---           | 
| Easy to find related code(grouped in vertical slices) | |
| Is posibble in some languages to hide code that other pieces shouldn't know | Sometimes is needed to share pieces between vertical slices and encapsulation is broken |
* Component

![Alt component](art/COMPONENT.png)

| *PROS* | *CONS* | 
| :---         | :---           | 
| Guide developers to use the architecture as we designed it | |
| Compile time boundaries to use good practices | |
| Avoid long sessions checking PR(or skipping) to find undesirable code | |
| Avoid publishing dependencies from the core that can be used only internally | |

### <u>Package by component</u>
* Problem:

Find a way to built highly reusable pieces of code. Separate application user interface/presentation and use cases in a scalable way.

* Solution:

Build a component that solves the problem, leveraging the presentation details to an outter layer. This way the core can be used along the app, and minimize the coupling between the app layer and our core component.

![Alt mvc](art/component-arch.png)
<!--- Commented until a framework is created with some component
<b>Swift</b>

In swift we can use a .framework to create our components(Core) and import them in our project(App). This way we can hide internal dependencies of the core and only expose the minimun needed dependencies from the use case perspective. We should use internal access modifiers to avoid publishing non needed dependencies outside of the core, this way we guide developers to a avoid a bad usage of the core. If you need more info on how to create a .framework you can check this [link](https://medium.com/captain-ios-experts/develop-a-swift-framework-1c7fdda27bf1)


* Example usage of PlacesComponent([Core framework](https://github.com/albertopeam/clean-architecture/blob/master/iOS/Project/CleanArchitecture/core/))

1. import framework: import CleanArchitectureCore
2. create the component: PlacesComponent.assemble(apiKey: "your-google-api-key")
3. use the component: places.nearby(output: PlacesOutputProtocol)
4. handle result/error in PlacesOutputProtocol defined methods

```swift
import CleanArchitectureCore

class NearbyPlacesPresenter:PlacesOutputProtocol {

let places:PlacesProtocol = PlacesComponent.assemble(apiKey: Constants.googleApiKey)

func nearbyPlaces() {            
places.nearby(output: self)
}

func onNearby(places: Array<Place>) {
//handle result
}

func onNearbyError(error: Error) {
//handle error
}
}
```

* Usefull links:
* [Full example](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitecture/app/places/NearbyPlacesPresenter.swift)
-->

## Patterns
### Promises
* Problem:

One of the most common pitfalls which developers who use asynchronous APIS can find is callback hell.
Sometimes the nature of the APIS that we use instigate us to nest async code. At the start maybe we can manage it, but when 
the system becomes bigger and bigger it will become a problem because the code will be too complex to read and test.

#### Swift: Legacy

 ```swift
func fetchData(callback:Callback){
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!) { (data, response, error) in
        if error != nil {
            DispatchQueue.main.sync {
                callback.error(nil, error)
            }
        }else{
            let url2 = URL(string: urlString2)
            URLSession.shared.dataTask(with: url2!) { (data, response, error) in
                DispatchQueue.main.sync {
                    if error != nil {
                        callback.error(nil, error)
                    }else{
                        callback.success(data, nil)
                    }
                }
            }.resume()
        }
    }.resume()
}
 ```
* Solution: 

To apply a pattern that allows us to hide the complexity of multiple asynchronous operations and provide a way to handle them avoiding nesting blocks. 
A promise represents the eventual result of an asynchronous operation; we can chain as many promises as we want.

#### Swift: Serial work

```swift
class Places:PlacesProtocol {

    private let locationWorker:Worker
    private let placesGateway:Worker
    
    func nearby(output: PlacesOutputProtocol) {
        Promises.once(worker: locationWorker, params: nil)
        .then(completable: { (location) -> PromiseProtocol in
            return Promises.once(worker: self.placesGateway, params:location)
        }).then(finalizable: { (places) in
            output.onNearby(places: places as! Array<Place>)
        }).error(rejectable: { (error) in
            output.onNearbyError(error: error)
        })
    }
}

class PlacesGateway:NSObject, Worker {    
    func run(params:Any?, resolve: @escaping ResolvableWorker, reject: @escaping RejectableWorker) throws {
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.sync {
                    reject(self, error)
                }
            }else{
                DispatchQueue.main.sync {
                    resolve(self, data)
                }
            }
        }.resume()
    }
}
```

If you need to dispatch N requests or do something in parallel you can use promises also. For that use Promises.all method in Promises class. The promise will return when all the request will be executed, if some of them fails the it will dispatch an error.

#### Swift: Parallel work
```swift
class Weather:WeatherProtocol {
    
    private let currentWeatherWorkers:Array<Worker>
    
    func current(output: WeatherOutputProtocol) {
        Promises.all(workers:currentWeatherWorkers)
        .then(finalizable: { (items) in
            output.onWeather(items: items as! Array<InstantWeather>)
        }).error(rejectable: { (error) in
            output.onWeatherError(error: error)
        })
    }
}
```

* Usefull links:
    * [Code: Serial promises](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitecture/core/places/Places.swift)
    * [Code: Parallel promises](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitecture/core/weather/Weather.swift)
    * [Test: UseCase](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitectureTests/core/places/PlacesTest.swift)
    * [Test: Worker](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitectureTests/core/places/PlacesWorkerTest.swift)

| *PROS* | *CONS* | 
| :---         | :---           | 
| Avoid callback hell | Use of casts in completion blocks |
| The code is easier to read and mantain  | |
| Better error handling(unified) | |
| Asynchronous API for sync and async operations  | |
| High scalability when using multiple workers | |
| Can be used with any third party async and sync APIs | |
| Custom solution(this is a pattern) that avoid the usage of third party lib | |
| Produce easy and complete testable code | |
| Helps for decoupling between use cases and data gateways | |

* UML

     ![Alt promise](art/PROMISE.png)
    
### MVVM(model view view-model)
* Problem: 

Coupling between the view and the model. Sometimes the view has many responsabilities, so we ending with a view that knows the model and how to format the data that it contains, so this produce views with more than one responsability.

```swift
class UVIndexViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!    

    ...

    func onUVIndex(ultravioletIndex: UltravioletIndex) { 
        //ViewController knows the model and how to format the data that the model contains
        let date = Date(timeIntervalSince1970:Double(ultravioletIndex.timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        var formattedDate = dateFormatter.string(from: date)         
        self.dateLabel.text = formattedDate

        var description = "Unknown"
        if ultravioletIndex.uvIndex >= 0 && ultravioletIndex.uvIndex < 3 {
            description = "Low"
        } else if ultravioletIndex.uvIndex >= 3 && ultravioletIndex.uvIndex < 6 {
            description = "Moderate"
        } else if ultravioletIndex.uvIndex >= 6 && ultravioletIndex.uvIndex < 8 {
            description = "High"
        } else if ultravioletIndex.uvIndex >= 8 && ultravioletIndex.uvIndex < 11 {
            description = "Very high"
        } else if ultravioletIndex.uvIndex >= 11 {
            description = "Extreme"
        }
        self.descriptionLabel.text = description  
    }
}
```

* Solution:
Applying MVVM pattern the presentation logic is handled by the view-model so the view isn't aware of changes on how the data should be presented. To achieve this the view must register against observable properties in the view-model, when those properties are changed by the view-model the view will receive an event indicating that a new value is avaliable.

#### Swift: Observer
In swift there isn't native library that supports model view view-model, so to achieve this we can use a another pattern called observer. This will be the bridge between the view and view-model
```swift
class Observable<T> {
    
    typealias Observer = (T) -> Void
    private var observer:Observer?
    
    var value:T {
        didSet{
            observer?(value)
        }
    }
    
    init(value:T) {
        self.value = value
    }
    
    func bind(observer:@escaping Observer) {
        self.observer = observer
        observer(value)
    }
}
```

#### Swift: View-model
```swift
class UVIndexViewModel:UVIndexViewModelProtocol, UVIndexOutputProtocol {

    let descriptionObservable = Observable<String>(value: "")
    let dateObservable = Observable<String>(value: "")
    
    ...

    func onUVIndex(ultravioletIndex: UltravioletIndex) {        
        let date = Date(timeIntervalSince1970:Double(ultravioletIndex.timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateObservable.value = dateFormatter.string(from: date)         

        var description = "Unknown"
        if ultravioletIndex.uvIndex >= 0 && ultravioletIndex.uvIndex < 3 {
            description = "Low"
        } else if ultravioletIndex.uvIndex >= 3 && ultravioletIndex.uvIndex < 6 {
            description = "Moderate"
        } else if ultravioletIndex.uvIndex >= 6 && ultravioletIndex.uvIndex < 8 {
            description = "High"
        } else if ultravioletIndex.uvIndex >= 8 && ultravioletIndex.uvIndex < 11 {
            description = "Very high"
        } else if ultravioletIndex.uvIndex >= 11 {
            description = "Extreme"
        }
        descriptionObservable.value = description        
    }
}
```

#### Swift: View
```swift
class UVIndexViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!    
    private let viewModel:UVIndexViewModelProtocol
    
    ...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind(){        
        viewModel.descriptionObservable.bind { [weak self] (newValue) in
            self?.descriptionLabel.text = newValue
        }
        viewModel.dateObservable.bind { [weak self] (newValue) in
            self?.dateLabel.text = newValue
        }
    }
}

```

#### Swift: Reusing View-Model in TodayExtension
```swift
class TodayViewController: UIViewController {
        
    @IBOutlet weak var ultravioletIndexLabel: UILabel!    
    var viewModel:UVIndexViewModel?
    var completion:Completion?
    
    ...
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        bind()
    }
    
    private func bind(){        
        viewModel?.uvIndexObservable.bind { [weak self] (newValue) in
            self?.ultravioletIndexLabel?.text = newValue
            self?.completion?(NCUpdateResult.newData)
        }      
    }    
}

extension TodayViewController:NCWidgetProviding{
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        viewModel?.loadUVIndex()
        completion = completionHandler
    }
}
```

* Useful links:
  
    * [Code: View Controller](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitecture/app/uvindex/UVIndexViewController.swift)
    * [Code: View Model](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitecture/app/uvindex/UVIndexViewModel.swift)
    * [Code: Widget](https://github.com/albertopeam/clean-architecture/blob/master/iOS/UltravioletIndexWidget/TodayViewController.swift)
    * [Testing: View Model](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitectureTests/app/uvindex/UVIndexViewModelTest.swift)
    * [Testing: View Controller](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitectureUITests/app/uvindex/UVIndexViewControllerTest.swift)
 
  
| *PROS* | *CONS* | 
| :---         | :---           | 
| Decouple model and view | It can be an problem if the view-model has tons of properties |
| Decouple presentation logic from the view |  |
| Respect single responsability principle |  |
| Simplified view, it only does UI operations | |
| Reusability of the view-model in other views | |

* UML

     ![Alt mvvm](art/MVVM.png)

## Testing
* under development
    * UNIT docu
    * UI: docu
        * pending:
            KIF+Snapshot 
            https://github.com/kif-framework/KIF
            https://github.com/uber/ios-snapshot-test-case/

## License
Copyright (c) 2018 Alberto Penas Amor

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
