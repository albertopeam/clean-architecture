# Clean Architecture

The intention of this repo is to show the more common practices when you build a mobile app using clean architecture

WORK IN PROGRESS

## Before start
* iOS
    * Resolve Carthage dependencies. For more [info](https://github.com/Carthage/Carthage)
    ```
    carthage update --platform iOS
    ```
    * To run the project you should create a file called Constants with your own Google Api Key. For more [info](https://developers.google.com/places/web-service/search)
    ```
        class Constants {
            static let googleApiKey = "add-your-own-key"
        }
    ```

## Project structure
* iOS folder -> Swift iOS project

## Development
* app/places: shows a list of places near your current location

### Pending
* iOS
    * Places testing
    * UI testing
    * move PlacesComponents to a module to avoid publish internal dependencies(do another entry with the explanation)

### Next
* iOS
    * observer

## Tests
* iOS

## Patterns
### <u>Promise</u>
* Problem:

One of the most commnon pitfalls of developers who use asynchronous frameworks is callback hell.
Sometimes the nature of the libraries or the framework that we use instigate us to nest async code. At the start maybe we can manage it, but when 
the system become more and more big it will be a problem because the code will be complex to read and understand.
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

Apply a pattern that allows us to hide the complexity of the asynchronous operations and provide a way to handle them as if they were synchronous. 
A promise represents the eventual result of an asynchronous operation, we can chain as many promises as we want in a synchronous way.
```swift
let fetchWork1:Work1
let fetchWork2:Work2

func fetchData(callback:Callback) {
    Promise(work: fetchWork1)
    .then { (result) -> Promise in
        return Promise(work: fetchWork2, params:result)
    }.then { (result) in
        callback.success(result: result)
    }.error { (error) in
        callback.error(error: error)
    }
}

class Work1:NSObject, Work {
    func run(params:Any?, resolve: @escaping (Any) -> Void, reject: @escaping Reject) throws {
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            DispatchQueue.main.sync {
                if error != nil {
                    reject(error!)
                }else{
                    resolve(data!)
                }
            }
        }.resume()
    }
}
```
| *PROS* | *CONS* | 
| :---         | :---           | 
| Avoid callback hell | Understand the promise concept and how it works |
| The code is more easy to read and mantain  | | 
| Better error handling(unified) | |
| Asynchronous API for sync and async operations  | |

* Examples:
    * [Swift](https://github.com/albertopeam/clean-architecture/blob/master/iOS/CleanArchitecture/core/places/Places.swift)

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
