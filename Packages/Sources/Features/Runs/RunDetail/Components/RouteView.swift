import MapKit
import Model
import SwiftUI

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

private struct _Map: UIViewRepresentable {
    class _Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 2
            return renderer
        }
    }

    let locations: [Location]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = MKCoordinateRegion(coordinates: locations)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context _: Context) {
        let coordinates = locations.map { location in CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        }

        let polyline = MKPolyline(coordinates: coordinates, count: locations.count)
        view.addOverlay(polyline)
    }

    func makeCoordinator() -> _Coordinator {
        _Coordinator()
    }
}

struct RouteView: View {
    let locations: [Location]

    var body: some View {
        _Map(locations: locations)
    }
}

#Preview {
    RouteView(locations: .loop)
}
