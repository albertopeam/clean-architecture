//
//  Polyline.swift
//  sufisio
//
//  Created by Penas Amor, Alberto on 18/4/18.
//  Copyright © 2018 Sufisio. All rights reserved.
//

import MapKit

//objc  version: https://stackoverflow.com/questions/9217274/how-to-decode-the-google-directions-api-polylines-field-into-lat-long-points-in
//swift version: https://github.com/ziyang0621/MKMapSample/blob/master/MKMapSample/ViewController.swift
extension MKPolyline {
    
    static func polyLine(encodedString: String) -> MKPolyline {
        let bytes = (encodedString as NSString).utf8String
        let length = encodedString.lengthOfBytes(using: String.Encoding.utf8)
        var idx: Int = 0
        
        var count = length / 4
        var coords = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: count)
        var coordIdx: Int = 0
        
        var latitude: Double = 0
        var longitude: Double = 0
        
        while (idx < length) {
            var byte = 0
            var res = 0
            var shift = 0
            
            repeat {
                byte = Int(bytes![idx].advanced(by: -0x3F))
                idx += 1
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            
            let deltaLat = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            latitude += Double(deltaLat)
            
            shift = 0
            res = 0
            
            repeat {
                byte = Int(bytes![idx].advanced(by: -0x3F))
                idx += 1
                res |= (byte & 0x1F) << shift
                shift += 5
            } while (byte >= 0x20)
            
            let deltaLon = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
            longitude += Double(deltaLon)
            
            let finalLat: Double = latitude * 1E-5
            let finalLon: Double = longitude * 1E-5
            
            let coord = CLLocationCoordinate2DMake(finalLat, finalLon)
            coords[coordIdx] = coord
            coordIdx += 1
            
            if coordIdx == count {
                let newCount = count + 10
                let temp = coords
                coords.deallocate(capacity: count)
                coords = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: newCount)
                for index in 0..<count {
                    coords[index] = temp[index]
                }
                temp.deinitialize()
                count = newCount
            }
            
        }
        
        let polyLine = MKPolyline(coordinates: coords, count: coordIdx)
        coords.deinitialize()
        
        return polyLine
    }
    
}
