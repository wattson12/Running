import Foundation
import MapKit
import Model
import SwiftUI

struct MapView: UIViewRepresentable {
    class Coordinator: NSObject, MKMapViewDelegate {
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

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
