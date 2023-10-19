import Foundation
import MapKit
import Model

extension MKCoordinateRegion {
    init(coordinates: [Location]) {
        var minLat: CLLocationDegrees = 90.0
        var maxLat: CLLocationDegrees = -90.0
        var minLon: CLLocationDegrees = 180.0
        var maxLon: CLLocationDegrees = -180.0

        for coordinate in coordinates {
            let lat = coordinate.coordinate.latitude
            let long = coordinate.coordinate.longitude
            if lat < minLat {
                minLat = lat
            }
            if long < minLon {
                minLon = long
            }
            if lat > maxLat {
                maxLat = lat
            }
            if long > maxLon {
                maxLon = long
            }
        }

        let span = MKCoordinateSpan(
            latitudeDelta: maxLat - minLat,
            longitudeDelta: maxLon - minLon
        )
        let center = CLLocationCoordinate2D(
            latitude: maxLat - span.latitudeDelta / 2,
            longitude: maxLon - span.longitudeDelta / 2
        )
        self.init(center: center, span: span)
    }
}
