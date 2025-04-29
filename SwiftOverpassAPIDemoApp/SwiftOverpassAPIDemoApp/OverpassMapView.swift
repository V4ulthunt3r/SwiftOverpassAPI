import SwiftUI
import MapKit
import SwiftOverpassAPI

struct OverpassMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let viewModel: OverpassMapViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Register gesture recognizers
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture(_:)))
        mapView.addGestureRecognizer(panGesture)
        mapView.addGestureRecognizer(pinchGesture)
        
        // Setup view model
        viewModel.setRegion = { region in
            mapView.setRegion(region, animated: true)
        }
        viewModel.addAnnotations = { annotations in
            mapView.addAnnotations(annotations)
        }
        viewModel.addOverlays = { overlays in
            mapView.addOverlays(overlays)
        }
        viewModel.removeAnnotations = { annotations in
            mapView.removeAnnotations(annotations)
        }
        viewModel.removeOverlays = { overlays in
            mapView.removeOverlays(overlays)
        }
        
        viewModel.registerAnnotationViews(to: mapView)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: OverpassMapView
        
        init(_ parent: OverpassMapView) {
            self.parent = parent
        }
        
        @objc func handleGesture(_ sender: UIGestureRecognizer) {
            parent.viewModel.userDidGestureOnMapView(sender: sender)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            return parent.viewModel.view(for: annotation)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            return parent.viewModel.renderer(for: overlay)
        }
    }
} 