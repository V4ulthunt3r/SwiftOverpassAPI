import MapKit
import SwiftOverpassAPI
import Combine

protocol MapViewModel: NSObject {
    var region: MKCoordinateRegion? { get }
    var annotations: [MKAnnotation] { get }
    var overlays: [MKOverlay] { get }
    var setRegion: ((MKCoordinateRegion) -> Void)? { get set }
    var addAnnotations: (([MKAnnotation]) -> Void)? { get set }
    var addOverlays: (([MKOverlay]) -> Void)? { get set }
    var removeAnnotations: (([MKAnnotation]) -> Void)? { get set }
    var removeOverlays: (([MKOverlay]) -> Void)? { get set }
    
    func registerAnnotationViews(to mapView: MKMapView)
    func renderer(for overlay: MKOverlay) -> MKOverlayRenderer
    func view(for annotation: MKAnnotation) -> MKAnnotationView?
    func userDidGestureOnMapView(sender: UIGestureRecognizer)
}

class OverpassMapViewModel: NSObject, MapViewModel, ObservableObject {
    @Published var visualizations = [Int: OPMapKitVisualization]()
    @Published var annotations = [MKAnnotation]()
    @Published var overlays = [MKOverlay]()
    @Published var region: MKCoordinateRegion?
    
    private let markerReuseIdentifier = "MarkerAnnotationView"
    
    var setRegion: ((MKCoordinateRegion) -> Void)?
    var addAnnotations: (([MKAnnotation]) -> Void)?
    var addOverlays: (([MKOverlay]) -> Void)?
    var removeAnnotations: (([MKAnnotation]) -> Void)?
    var removeOverlays: (([MKOverlay]) -> Void)?
    
    func registerAnnotationViews(to mapView: MKMapView) {
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: markerReuseIdentifier
        )
    }
    
    func addVisualizations(_ visualizations: [Int: OPMapKitVisualization]) {
        self.visualizations = visualizations
        removeAnnotations?(annotations)
        removeOverlays?(overlays)
        
        annotations = []
        overlays = []
        
        var newAnnotations = [MKAnnotation]()
        var polylines = [MKPolyline]()
        var polygons = [MKPolygon]()
        
        for visualization in visualizations.values {
            switch visualization {
            case .annotation(let annotation):
                newAnnotations.append(annotation)
            case .polyline(let polyline):
                polylines.append(polyline)
            case .polylines(let newPolylines):
                polylines.append(contentsOf: newPolylines)
            case .polygon(let polygon):
                polygons.append(polygon)
            case .polygons(let newPolygons):
                polygons.append(contentsOf: newPolygons)
            }
        }
        
        let multiPolyline = MKMultiPolyline(polylines)
        let multiPolygon = MKMultiPolygon(polygons)
        
        let newOverlays: [MKOverlay] = [multiPolyline, multiPolygon]
        
        annotations = newAnnotations
        overlays = newOverlays
        
        addAnnotations?(annotations)
        addOverlays?(overlays)
    }
    
    func centerMap(onVisualizationWithId id: Int) {
        guard let visualization = visualizations[id] else { return }
        
        let region: MKCoordinateRegion
        let insetRatio: Double = -0.25
        let boundingRects: [MKMapRect]
        
        switch visualization {
        case .annotation(let annotation):
            region = MKCoordinateRegion(
                center: annotation.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
            self.region = region
            return
        case .polyline(let polyline):
            boundingRects = [polyline.boundingMapRect]
        case .polygon(let polygon):
            boundingRects = [polygon.boundingMapRect]
        case .polylines(let polylines):
            boundingRects = polylines.map { $0.boundingMapRect }
        case .polygons(let polygons):
            boundingRects = polygons.map { $0.boundingMapRect }
        }
        
        guard
            let minX = (boundingRects.map { $0.minX }).min(),
            let maxX = (boundingRects.map { $0.maxX }).max(),
            let minY = (boundingRects.map { $0.minY }).min(),
            let maxY = (boundingRects.map { $0.maxY }).max()
        else { return }
        
        let width = maxX - minX
        let height = maxY - minY
        let rect = MKMapRect(x: minX, y: minY, width: width, height: height)
        let paddedRect = rect.insetBy(dx: width * insetRatio, dy: height * insetRatio)
        region = MKCoordinateRegion(paddedRect)
        self.region = region
    }
    
    func renderer(for overlay: MKOverlay) -> MKOverlayRenderer {
        let strokeWidth: CGFloat = 2
        let strokeColor = UIColor.systemPurple
        let fillColor = UIColor.systemPurple.withAlphaComponent(0.5)
        
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = strokeColor
            renderer.lineWidth = strokeWidth
            return renderer
        } else if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = fillColor
            renderer.strokeColor = strokeColor
            renderer.lineWidth = strokeWidth
            return renderer
        } else if let multiPolyline = overlay as? MKMultiPolyline {
            let renderer = MKMultiPolylineRenderer(multiPolyline: multiPolyline)
            renderer.strokeColor = strokeColor
            renderer.lineWidth = strokeWidth
            return renderer
        } else if let multiPolygon = overlay as? MKMultiPolygon {
            let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
            renderer.fillColor = fillColor
            renderer.strokeColor = strokeColor
            renderer.lineWidth = strokeWidth
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func view(for annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pointAnnotation = annotation as? MKPointAnnotation else { return nil }
        
        let view = MKMarkerAnnotationView(
            annotation: pointAnnotation,
            reuseIdentifier: markerReuseIdentifier
        )
        view.markerTintColor = .systemPurple
        return view
    }
    
    func userDidGestureOnMapView(sender: UIGestureRecognizer) {
        if sender.isKind(of: UIPanGestureRecognizer.self) ||
           sender.isKind(of: UIPinchGestureRecognizer.self) {
            region = nil
        }
    }
} 
