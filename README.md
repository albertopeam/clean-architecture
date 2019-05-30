# Clean Architecture

[![Build Status](https://travis-ci.org/albertopeam/clean-architecture.svg?branch=master)](https://travis-ci.org/albertopeam/clean-architecture)
[![codecov](https://codecov.io/gh/albertopeam/clean-architecture/branch/master/graph/badge.svg)](https://codecov.io/gh/albertopeam/clean-architecture)
[![Maintainability](https://api.codeclimate.com/v1/badges/574acc8910d2d786349b/maintainability)](https://codeclimate.com/github/albertopeam/clean-architecture/maintainability)
[![Swift Version](https://img.shields.io/badge/Swift-5.0-F16D39.svg?style=flat)](https://developer.apple.com/swift)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
 
The intention of this repository is to show some of the more common practices when building a mobile app using clean architecture.

## Table of Contents
- [Clean Architecture](#clean-architecture)
  - [Table of Contents](#table-of-contents)
  - [Before start](#before-start)
    - [App](#app)
    - [Extensions](#extensions)
    - [Testing](#testing)
  - [Project structure](#project-structure)
  - [What do you expect to see soon?](#what-do-you-expect-to-see-soon)
    - [Next](#next)
  - [Architecture](#architecture)
    - [Packaging](#packaging)
    - [<u>Package by component</u>](#upackage-by-componentu)
  - [Patterns](#patterns)
    - [Promises](#promises)
      - [Swift: Legacy](#swift-legacy)
      - [Swift: Serial work](#swift-serial-work)
      - [Swift: Parallel work](#swift-parallel-work)
      - [Swift: Sundell](#swift-sundell)
    - [MVVM(model view view-model)](#mvvmmodel-view-view-model)
      - [Swift: Observer](#swift-observer)
      - [Swift: View-model](#swift-view-model)
      - [Swift: View](#swift-view)
      - [Swift: Reusing View-Model in TodayExtension](#swift-reusing-view-model-in-todayextension)
    - [MVP(model view presenter)](#mvpmodel-view-presenter)
      - [Swift: View](#swift-view-1)
      - [Swift: Presenter](#swift-presenter)
  - [Testing](#testing-1)
    - [Unit testing](#unit-testing)
      - [How to start?](#how-to-start)
      - [Swift: unit test without dependencies](#swift-unit-test-without-dependencies)
      - [Swift: unit test with dependencies(Mock/Stub/Fake/Dummy)](#swift-unit-test-with-dependenciesmockstubfakedummy)
      - [Swift: unit test with dependencies(Spy)](#swift-unit-test-with-dependenciesspy)
    - [Integration testing](#integration-testing)
    - [HTTP testing](#http-testing)
    - [UI testing](#ui-testing)
    - [Functional testing](#functional-testing)
    - [Snapshot testing](#snapshot-testing)
  - [License](#license)
  
## Before start

* Resolve Carthage dependencies. For more [info](https://github.com/Carthage/Carthage)
```
carthage update --platform iOS
```
 * To run the project you should fill the Constants with your own Google Api Key and OpenWeather Api Key. For more [Google info](https://developers.google.com/places/web-service/search), for more [Open weather info](https://openweathermap.org/appid)
```
    class Constants {
        static let googleApiKey = "add-your-own-key"
        static let openWeatherApiKey = "add-your-own-key"
    }
```

### App
* app/places: shows a list of places near your current location
* app/weather/weather: shows the weather in a list of places.
* app/weather/current: shows the weather in your current location.
* app/uvindex: shows the ultraviolet index in your current location.
* app/airquality: shows the air quality index in your current location.

### Extensions
* UltravioletIndexWidget: shows the ultraviolet index in your current location on a widget.

### Testing
* You can check the coverage on [codecov](https://codecov.io/gh/albertopeam/clean-architecture)

<!---
## Project structure
* iOS folder -> Swift iOS project
--->
## What do you expect to see soon?
### Next
* Inject Constants from Environment instead of hardcode it in the app
* Framework usage to avoid all the code to seen as public
* View State pattern for complex UIs
* Repository pattern
* Robots Pattern(Testing) <!-- https://academy.realm.io/posts/kau-jake-wharton-testing-robots/ -->

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

#### Swift: Sundell
Same flavour but this time an original work by [Sundell](https://www.swiftbysundell.com/posts/under-the-hood-of-futures-and-promises-in-swift)

You could see that in this example we are using *chained* instead of *then* and *observe* for final result or error.
```swift
    locationJob.location().chained { (location) -> Future<InstantWeather> in
        return self.weatherJob.weather(location: location)
    }.observe { (result) in
        switch result {
        case .value(let weather):
            output.weather(weather: weather)
        case .error(let error):                
            output.weatherError(error: .error)                
        }
    }
```

* Usefull links:
    * [Code: Serial promise](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/core/places/Places.swift)    
    * [Test: Serial promise UseCase](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureTests/core/places/PlacesTest.swift)
    * [Test: Serial promise Worker](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureTests/core/places/PlacesWorkerTest.swift)
    * [Code: Parallel promises](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/core/weather/weather/Weather.swift)
    * [Code: Sundell promises](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/core/weather/current/CurrentWeather.swift)
    * [Test: Sundell promises](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureTests/core/weather/current/CurrentWeatherTests.swift)

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
| Low technical debt | |

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
  
    * [Code: View Controller](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/app/uvindex/UVIndexViewController.swift)
    * [Code: View Model](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/app/uvindex/UVIndexViewModel.swift)
    * [Code: Widget](https://github.com/albertopeam/clean-architecture/blob/master/UltravioletIndexWidget/TodayViewController.swift)
    * [Testing: View Controller](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureUITests/app/uvindex/UVIndexViewControllerTest.swift)
    * [Testing: View Model](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureTests/app/uvindex/UVIndexViewModelTest.swift)
  
| *PROS* | *CONS* | 
| :---         | :---           | 
| Decouple model and view | It can be an problem if the view-model has tons of properties |
| Decouple presentation logic from the view |  |
| Respect single responsability principle |  |
| Simplified view, it only does UI operations | |
| Reusability of the view-model in other views | |
| Easy to test objects with only one responsabilty | |

* UML

     ![Alt mvvm](art/MVVM.png)

### MVP(model view presenter)
* Problem: 
    *  Sometimes the presentation logic is coupled to the view, as result of this the view has at least two responsabilities: manipulate the view and know how to format the data.

```swift
class NearbyPlacesViewController: UIViewController, NearbyPlacesViewProtocol {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesTableView: UITableView!

    ...
    
    func onNearby(result: Array<Place>) {
        if let places = result {
            var locations = Array<MKPointAnnotation>()
            for place in places {
                let location = MKPointAnnotation()
                location.coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
                location.title = place.name
                mapView.addAnnotation(location)
                locations.append(location)
            }
            mapView.removeAnnotations(mapView.annotations)
            mapView.showAnnotations(locations, animated: true)
            mapView.delegate = self
            placesTableView.reloadData()
        }else{
            ...
        }
    }
    
    func onNearbyError(err: Error) {
        var requestPermission = false
        var error:String? = nil
        switch err {
            case LocationError.noLocationPermission:
                requestPermission = true
            case LocationError.deniedLocationUsage:
                error = "Denied location usage"
            case LocationError.restrictedLocationUsage:
                error = "Restricted location usage"
            case LocationError.noLocationEnabled:
                error = "No location enabled"
            case LocationError.noLocation:
                error = "No location available"
            case PlacesError.noNetwork:
                error = "No network"
            case PlacesError.decoding:
                error = "Internal error"
            case PlacesError.timeout:
                error = "Try again, timeout"
            case PlacesError.noPlaces:
                error = "No results"
            case PlacesError.badStatus:
                error = "Interal problem, Google API request denied"
            default:
                break
        }
        if error != nil {
            presentAlert(title: "Error", message: error, button: "Ok")
        }else if requestPermission {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

```

* Solution:
    * Provide a mediator, the presenter. It will act as middleware between the model and the view and it will handle the presentation logic.

#### Swift: View
```swift
class NearbyPlacesViewController: UIViewController, NearbyPlacesViewProtocol {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var reloadNearbyButton: UIButton!
   
    ...
    
    func newState(viewState: NearbyPlacesViewState) {
        if let places = viewState.places {
            self.places = places
            var locations = Array<MKPointAnnotation>()
            for place in places {
                let location = MKPointAnnotation()
                location.coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
                location.title = place.name
                mapView.addAnnotation(location)
                locations.append(location)
            }
            mapView.removeAnnotations(mapView.annotations)
            mapView.showAnnotations(locations, animated: true)
            mapView.delegate = self
            placesTableView.reloadData()
        }
        if let error = viewState.error {
            presentAlert(title: "Error", message: error, button: "Ok")
        }
        if viewState.requestPermission {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
```

#### Swift: Presenter
```swift
struct NearbyPlacesViewState {
    let places:Array<Place>?
    let error:String?
    let requestPermission:Bool
}

class NearbyPlacesPresenter:NearbyPlacesPresenterProtocol, PlacesOutputProtocol {
    
    ...
    
    func onNearby(places: Array<Place>) {
        view?.newState(viewState: NearbyPlacesViewState(places: places, error: nil, requestPermission: false))
    }
    
    func onNearbyError(error: Error) {
        let parsedError = parseError(error: error)
        view?.newState(viewState: NearbyPlacesViewState(places: nil, error: parsedError.error, requestPermission: parsedError.reqPermission))
    }
    
    func parseError(error:Error) -> (reqPermission:Bool, error:String?) {
        switch error{
        case LocationError.noLocationPermission:
            return (true, nil)
        case LocationError.deniedLocationUsage:
            return (false, "Denied location usage")
        case LocationError.restrictedLocationUsage:
            return (false, "Restricted location usage")
        case LocationError.noLocationEnabled:
            return (false, "No location enabled")
        case LocationError.noLocation:
            return (false, "No location available")
        case PlacesError.noNetwork:
            return (false, "No network")
        case PlacesError.decoding:
            return (false, "Internal error")
        case PlacesError.timeout:
            return (false, "Try again, timeout")
        case PlacesError.noPlaces:
            return (false, "No results")
        case PlacesError.badStatus:
            return (false, "Interal problem, Google API request denied")
        default:
            return (false, "Unkown error")
        }
    }
}
```

* Useful links:
    * [Code: View Controller](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/app/places/NearbyPlacesViewController.swift)
    * [Code: Presenter](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/app/places/NearbyPlacesPresenter.swift)    
    * [Testing: View Controller](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureUITests/app/places/PlacesViewControllerUITest.swift)
    * [Testing: Presenter](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureTests/app/places/PlacesPresenterTest.swift)

* UML
    
    ![Alt mvvm](art/MVP.png)
  
| *PROS* | *CONS* | 
| :---         | :---           | 
| Decouple presentation logic and view | |
| Transfer of the the state in one shot | One model more to mantain: ViewState |
| Using a ViewState model we can avoid long API interfaces between presenter and view that do micro changes in the state of the view | |
| Produce one responsability object | |
| Easy to test objects with only one responsabilty | |
    
## Testing

### Unit testing 
 * Is a method by which individual or sets units of source code are tested to determine whether they are fit for use.
 * Testing usually is tricky, most of the time the pieces of code that we test are composed by tons of dependencies. To avoid test a big system with a lot of dependencies we should focus on small bytes of code(usually one class), to do this we use test doubles to have a controlled environment for the dependencies that the class under test is using.
   * Test doubles by [Martin Fowler](https://martinfowler.com/bliki/TestDouble.html): 
     * Dummy: not used directly, needed to fill parameters.
     * Fake: it has working implementation, but it provides a shortcut that is not available in production.
     * Stubs: provide canned answers to calls made during the test.
     * Spies: record information based on how they were called.
     * Mocks: provide pre-programmed answers to the calls that they expect to receive. Can thrown exceptions if they execute code that is not supposed to. 
 * To summarize on how to proceed to create a test:
   * Choose a class to test
   * Create test class
   * Instanciate the subject under test
   * Resolve sut dependencies through the using of test doubles
   * Create test cases covering all equivalence classes using test doubles
 
#### How to start?
 * When you create a XCode project it gives you the posibility to create a unit testing target. If you haven't created one, you can create from srcatch a unit test target.
 * As a good practice we will try to follow the next rules when coding tests:
   * Mantaining the sources of code and the tests in the same directories in both targets.
   * Name test class with the name of the source plus *Tests*
   * Use *sut* as name of the unit being tested.
   * Use *given/when/then* convention to name the test functions.
   * Try to find all equivalences classes. It divides the input data of a software unit into partitions of equivalent data from which test cases can be derived.
   * Always make at least one assertion, if not the test doesn't add value. XCTest framework will help us to do it.
   * Private methods must be tested indirectly through the public API interface of the subject under test, to achieve this goal easily we can use test doubles.
   * Never test systems through network calls or systems that can provide failures due to external factors.
   
#### Swift: unit test without dependencies

This kind of tests usually are the ones that don't have dependencies, so we don't need to resolve external dependencies with test doubles. We only need to focus on the public API interface to create the test cases.

The next sample is very small and covers a small class called *Sample*, it is a simple one that only returns empty if content is nil or the current content if not nil.

```swift
class Sample {

    var content: String?

    func run() -> String {
        if let notNullContent = content {
            return notNullContent
        } else {
            return ""
        }
    }
}
```

There are a couple of test cases that cover all equivalence classes. The first one covers nil content(else branch of the *run* method for *Sample* class) and the second covers the not nil content.

```swift
import XCTest
class SampleTests: XCTestCase {

    func test_given_nil_content_when_run_then_return_empty() {
        var sut = Sample()
        
        let result = sut.run()
        
        XCTAssertEqual(result, "")
    }
    
    func test_given_not_nil_content_when_run_then_return_not_empty() {
        var sut = Sample()
        sut.content = "some content"
        
        let result = sut.run()
        
        XCTAssertEqual(result, sut.content)
    }
    
}
```

#### Swift: unit test with dependencies(Mock/Stub/Fake/Dummy)

Sometimes we will need to inject collborators instead of the objects used in production. This will help us recreating equivalence classes and simplify the test.
In this case we will have two main clases *Content* and *Sample*, doing the tests for *Sample* we will use a a *Mock* to replace *Content*.

```swift

class Content {
    
    private let content: String?
    
    init(content: String? = nil) {
        self.content = content
    }
    
    func get() throws -> String {
        guard let text = content else {
            throw NSError()
        }
        return text
    }
    
}

class Sample {
    
    let content: Content
    
    init(content: Content) {
        self.content = content
    }
    
    func run() -> String {
        do {
            return try content.get()
        } catch {
            return ""
        }
    }
    
}
```

There are a couple of test cases that cover all equivalence classes. Also a Mock object to avoid using the production *Content* and configure it to cover all the cases.
Please take note that *MockContent* uses a tricky technique to do the replacemet, we have a public var called *closure* that will be executed when the *get* function will be invoked, this way we can inject the desired behaviour through a functional approach.

```swift
class SampleTests: XCTestCase {
    
    func test_given_nil_content_when_run_then_return_empty() {
        let mockContent = MockContent()
        mockContent.closure = {
            throw NSError()
        }
        
        let sut = Sample(content: mockContent)
        let result = sut.run()
        
        XCTAssertEqual(result, "")
    }
    
    func test_given_not_nil_content_when_run_then_return_not_empty() {
        let mockContent = MockContent()
        let content = "sample"
        mockContent.closure = {
            return content
        }
        
        let sut = Sample(content: mockContent)
        let result = sut.run()
        
        XCTAssertEqual(result, content)
    }
    
}

private final class MockContent: Content {
    
    var closure: (() throws -> String)!
    
    override func get() throws -> String {
        return try closure()
    }
    
}
```

#### Swift: unit test with dependencies(Spy)

Sometimes the async nature of the code leads us to use spies to check if the result of the operation is what we expect.

There are some tools that will help us while we are testing async code.
  * [Nimble](https://github.com/Quick/Nimble) is used to express the expected outcomes of Swift expressions, it is very intuitive and provides a lot of matchers to easily do different kinds of assertions. 

XCTest framework also provides API's to test async code, but is a bit more verbose than Nimble, feel free to check the framework [XCTest expectations](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations)

Now the *Sample* class uses a block function to return the result of the call. The Queue is only needed for this example to recreate an async operation. The behaviour is the same as the previous examples.

```swift
class Sample {
    
    var content: String?
    
    func run(completion: @escaping (_ result: String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let notNullContent = self.content {
                completion(notNullContent)
            } else {
                completion("")
            }
        }
    }
    
}
```

In the next tests we are doing the Spying using function blocks. Nimble will help us to wait until the async operation is complete or timeout (default 1 second) finishes.

```swift
import XCTest
import Nimble

class SampleTests: XCTestCase {
    
    func test_given_nil_content_when_run_then_return_empty() {
        let sut = Sample()
        sut.content = nil
        
        var result: String?
        sut.run { (res) in
            result = res
        }
        
        expect(result).toEventually(beEmpty())
    }
    
    func test_given_not_nil_content_when_run_then_return_not_empty() {
        let content = "sample"
        let sut = Sample()
        sut.content = content
        
        var result: String?
        sut.run { (res) in
            result = res
        }
        
        expect(result).toEventually(equal(content))
    }
    
}
```

In this example we are doing the Spying using a class. The test is more readable but the quantity of code to write is bigger. This technique is used frequently when using protocols as a way to respond as response to an async operation. Nimble will help us to wait until the async operation is complete or timeout (default 1 second) finishes.

```swift
import XCTest
import Nimble

class SampleTests: XCTestCase {
    
    func test_given_nil_content_when_run_then_return_empty() {
        let spy = Spy()
        let sut = Sample()
        sut.content = nil
        
        sut.run(completion: spy.spy)
        
        expect(spy.result).toEventually(beEmpty())
    }
    
    func test_given_not_nil_content_when_run_then_return_not_empty() {
        let spy = Spy()
        let content = "sample"
        let sut = Sample()
        sut.content = content
        
        sut.run(completion: spy.spy)
        
        expect(spy.result).toEventually(equal(content))
    }
    
}

private final class Spy {
    
    var result: String!
    
    func spy(_ result: String) {
        self.result = result
    }
    
}
```

### Integration testing

Integration tests build on unit tests by combining the units of code and testing that the resulting combination functions correctly. Those kind of tests can and will use threads, access the database or do whatever is required to ensure that all of the code and the different environment changes will work correctly.

Also, integration tests don't necessarily prove that a complete feature works. The user may not care about the internal details of my programs, but I do!

TODO: WIP!

### HTTP testing

Http requests(the logic involved to parse the data, mappings, handle error cases, etc..) is an important part when doing unit testing, asserting that our app can handle correcly diferent network responses is very important to avoid unexpected scenarios. In this case is important to be sure that our app can handle successful requests(2xx and some 3xx) and the error ones, such as: no network, timeouts, 4xx, 5xx.

In next example we are going to test the happy path for a object that makes a GET request. 

The first step is to stub our network, to achieve that we are going to use OHTTPStubs, a great library to create network stubs. 
We want to be very assertive when stubing our requests, because we want to be sure that the request that is being made matches the technical criteria. In the next one we are asserting: `HTTP method`, `Host`, `Path` and `Query Params`. If all of these matches then the stub server will respond with the json data that we specify, if not we won't have any response from the server and the test will fail.

```swift
stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(fileAtPath: OHPathForFile("airquality-success.json", type(of: self))!,
                                    statusCode: 200,
                                    headers: ["Content-Type":"application/json"])
}.name = "air quality success request"
```

The next snippet is the complete test with setup and teardown fases. 
Is **important** to remove all stubs after each of our test cases to be sure they don't interfere with other test cases.
Is **interesting** to log the requests that are being stubbed per test.

```swift
class AirQualityWorkerTest: XCTestCase {

    private lazy var url = "https://\(host)\(path)?coordinates={{lat}},{{lon}}&limit=1&parameter=no2&has_geo=true"
    private let host = "any"
    private let path = "/v1/measurements"
    private let location = Location(latitude: 43.0, longitude: -8.1)
    private var sut: AirQualityWorker!
    private lazy var params = [
        "coordinates": "\(location.latitude),\(location.longitude)",
        "limit": "1",
        "parameter": "no2",
        "has_geo": "true"
    ]

    override func setUp() {
        super.setUp()
        sut = AirQualityWorker(url: url)
        OHHTTPStubs .removeAllStubs()
        OHHTTPStubs.onStubActivation { (request, stub, _) in
            print("** OHHTTPStubs: \(request.url!.absoluteString) stubbed by \(stub.name!). **")
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testGivenSuccessResponseWhenFetchThenMatchExpected() throws {
        stub(condition: isMethodGET() && isHost(host) && isPath(path) && containsQueryParams(params)) { (request) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("airquality-success.json", type(of: self))!,
                                        statusCode: 200,
                                        headers: ["Content-Type":"application/json"])
        }.name = "air quality success request"
        
        var result: AirQualityData?
        try sut.run(params: location, resolve: { (worker, res) in
            result = res as? AirQualityData
        }) { (worker, error) in }
        
        expect(result).toNotEventually(beNil())
        let unwrapped = try result.unwrap()
        expect(unwrapped.type).to(equal("no2"))
        expect(unwrapped.date).to(equal("utc-date"))
        expect(unwrapped.location.latitude).to(equal(43.0))
        expect(unwrapped.location.longitude).to(equal(-8.1))
        expect(unwrapped.measure.value).to(equal(10))
        expect(unwrapped.measure.unit).to(equal("µg/m³"))
    }

}
```

* Usefull links:
    * [Code: Worker Tests](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitectureTests/core/airquality/AirQualityWorkerTest.swift)   
    * [Code: Worker](https://github.com/albertopeam/clean-architecture/blob/master/CleanArchitecture/core/airquality/AirQualityWorker.swift)   

* Tools:
  * [Mock Server: OHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs)

### UI testing

UI testing gives us the ability to assert that our interface matches to the state that we expect in each scenario, the easier way to acomplish this is to use test doubles in some parts of the system. Usually we can use a double for the business logic and leave the presentation do its stuff when handling the UI.
This kind of tests have a big scope and are slow, but they provide value to test the state of our user interface.

First we need to use a test double to handle the business logic. This one uses a inyected closure to mock the behaviour, you can see it in action in the test.

```swift
private final class SuccessCurrentWeather: CurrentWeatherProtocol {
    
    var closure: ((_ output: CurrentWeatherOutputProtocol) -> Void)!
    
    func current(output: CurrentWeatherOutputProtocol) {
        closure(output)
    }

}
```

Now we create a test that assert the happy path, checks the UI for showing the current weather. For this case we use the mock created in the previous step and make the wiring for create the view controller. The final step is to assert the state of the view using KIF assertions.
```swift
import XCTest
@testable import CleanArchitecture

class CurrentWeatherViewControllerUITests: XCTestCase {

        func test_given_weather_data_when_load_view_then_match_wheater_is_loading() {
        let weather = InstantWeather(name: "Perillo",
                                     description: "description",
                                     icon: "icon",
                                     temp: 20.0,
                                     pressure: 1024.0,
                                     humidity: 75,
                                     windSpeed: 20,
                                     windDegrees: 90,
                                     datetime: 1545605544)
        let mockWeather = SuccessCurrentWeather()
        mockWeather.closure = { output in output.weather(weather: weather) }
        
        let vc = CurrentWeatherViewBuilder()
            .withCurrentWeather(currentWeather: mockWeather)
            .build()
        
        robot.present(vc: vc)
            .assertWeather()
    }

}
```

* Tools: 
    [KIF functional testing](https://github.com/kif-framework/KIF)

### Functional testing

Functional testing is a powerfull tool that give us the ability to test the system against the functional specifications. This kind of tests are hard to develop and mantain, but they are worthy when you need to test a system against their specs. The usual way to do this tests is manually, but it can be automated. To automate this kind of tests you should be very carefull with the outter systems which we are interacting, we want to test the system itself, no other external systems that we are dependent of. So in a ideal way, we should put some boundaries when doing this kind of tests. Thinks like communications through the network, this is the most common problem in this kind of tests, there are other like localization services or hardware sensors. The way we have to avoid this is to leave the system as it is except for this kind of interaction, we can use libraries or mock ourselves the external systems.

In the next example we are going to test a feature that given the current location we want to show the current weather for it. 
We are only covering the happy path. We don't want to create a excessive number of this kind of tests, because as we said are hard to mantain and very flaky when running due to timing, animations, etc...

The next two snippets are used to mock localization services and network layer. As we said we don't want to handle external systems that could lead to errors not expected during the execution of the test.

```swift
private final class MockLocationJob: LocationJob {
    
    private let mockLocation: Location
    
    init(mockLocation: Location) {
        self.mockLocation = mockLocation
    }
    
    override func location() -> Promise<Location> {
        return Promise<Location>(value: mockLocation)
    }
    
}
```

We are using *URLSession* to handle our network requests, so we can use a mocked one to inject the expected response. It is a bit tricky, we need to override *dataTask* method in *URLSession* and return a mocked *URLSessionDataTask* that is not going to make any request when the *resume* method will be invoked, it only is going to respond directly with the response that we inject in the mocked *URLSession*.

```swift
class MockURLSession: URLSession {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    var response: URLResponse = DummyURLResponse()
    
    init(data: Data) {
        self.data = data
    }

    override func dataTask(with url: URL,
                           completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        let response = self.response
        return MockURLSessionDataTask {
            completionHandler(data, response, error)
        }
    }
    
}

class MockURLSessionDataTask: URLSessionDataTask {
    
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
```

This is the happy path test. We are using a pattern called Robot to split the code of the test itself(setup and test doubles) and the needed interactions with the software.

```swift
import XCTest
@testable import CleanArchitecture

class CurrentWeatherViewControllerUITests: XCTestCase {
    
    private var robot: CurrentWeatherRobot!
    
    override func setUp() {
        super.setUp()
        robot = CurrentWeatherRobot(test: self)
    }
    
    override func tearDown() {
        robot = nil
        super.tearDown()
    }
    
    func test_given_success_response_weather_when_ask_current_weather_then_show_weather() {
        let mockSession = MockURLSession(data: weatherData())
        let vc = CurrentWeatherViewBuilder()
            .withLocationJob(locationJob: MockLocationJob(mockLocation: Location(latitude: 0.0, longitude: 0.0)))
            .withWeatherJob(weatherJob: CurrentWeatherJob(urlSession: mockSession))
            .build()        
        robot.present(vc: vc)
            .assertWeather()
    }
    
    private func weatherData() -> Data {
        let js: [String: Any] = [
            "cod": 200,
            "name": "Perillo",
            "dt": 1545605544,
            "weather": [[
                "description": "description",
                "icon": "icon"
                ]],
            "main": [
                "temp": 20.0,
                "pressure":1024.0,
                "humidity":75
            ],
            "wind": [
                "speed": 20,
                "deg": 90
            ]
        ]
        if let data = try? JSONSerialization.data(withJSONObject: js, options: .prettyPrinted) {
            return data
        }
        preconditionFailure("cannot convert to data")
    }
    
}
```

The Robot is a proxy to use KIF library, it contains all the intereactions with the user interface.

```swift
final class CurrentWeatherRobot: UIRobot {
 
    @discardableResult
    func present(vc: UIViewController) -> CurrentWeatherRobot {
        present(viewController: vc)
        return self
    }
    
    @discardableResult
    func assertWeather() -> CurrentWeatherRobot {
        tester!.waitForAbsenceOfView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.loading)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.city)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.description)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.humidity)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.pressure)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.pressure)
        tester!.waitForView(withAccessibilityIdentifier: CurrentWeatherViewController.AccessibilityIdentifiers.windSpeed)
        return self
    }
    
}
```

* Tools:
    * [KIF functional testing](https://github.com/kif-framework/KIF)

### Snapshot testing

Snapshot testing help us or the designers to check wether the current user interface matches the design. The idea is to put the user interface of the software in a determinate state and take a screenshot, this will be compared to another reference that is the expected one.

TODO: WIP!

* Tools: 
    [Snapshot](https://github.com/uber/ios-snapshot-test-case/)            

## License
Copyright (c) 2019 Alberto Penas Amor

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
