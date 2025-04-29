# SwiftOverpassAPI

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015+-blue.svg)](https://developer.apple.com/ios/)

<p align="center">
    <img src="Screenshots/max-morlock.png?raw=true" alt="Max-Morlock-Stadion"> 
</p>

A Swift module for querying, decoding, and visualizing Overpass API data. 

### **What is Overpass API?**

Overpass API is a read only database for querying open source mapping information provided by the OpenStreetMap project. For more information visit the [Overpass API Wiki](https://wiki.openstreetmap.org/wiki/Overpass_API) and the [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Main_Page). This package is a port of the cocoa pod https://github.com/ebsamson3/SwiftOverpassAPI with some adjustments.

## **Installation**

SwiftOverpassAPI is available through Swift Package Manager. To install it, add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/V4ulthunt3r/SwiftOverpassAPI.git", from: "0.1.3")
]
```

Or add it directly in Xcode:
1. Go to File > Add Packages...
2. Enter the repository URL: https://github.com/v4ulthunt3r/SwiftOverpassAPI.git
3. Click Add Package

## **Usage**

### **Creating a bounding box**

Create a boxed region that will confine your query:

**Option 1:** Initialize with a MKCoordinateRegion:
```swift
let center = CLLocationCoordinate2D(
	latitude: 49.450103,
	longitude: 11.075683)

let queryRegion = MKCoordinateRegion(
	center: center,
	latitudinalMeters: 50000,
	longitudinalMeters: 50000)

let boundingBox = OPBoundingBox(region: region)
```

**Option 2:** Initialize with latitudes and longitudes:
```swift
let boundingBox = OPBoundingBox(
	minLatitude: 38.62661651293796,
	minLongitude: -90.1998908782745,
	maxLatitude: 38.627383487062005,
	maxLongitude: -90.1989091217254)
```

### **Building a Query**

For simple query generation, you can use `OPQueryBuilder` class:

```swift
do {
	let query = try OPQueryBuilder()
		.setTimeOut(180) //1
		.setElementTypes([.relation]) //2
		.addTagFilter(key: "amenity", value: "biergarten") //3
		.addTagFilter(key: "name") //4
		.setBoundingBox(boundingBox) //5
		.setOutputType(.geometry) //6
		.buildQueryString() //7
} catch {
	print(error.localizedDescription)
}
```

1) Set a timeout for the server request
2) Set one or more element types that you wish to query (Any combination of `.node`, `.way` and/or `.relation`)
3) Filter for elements whose "amenity" tag's value is exactly "biergarten"
4) Filter for all elements with a "name" tag. Can have any associated value.
5) Query within the specified bounding box
6) Specify the output type of the query (See "Choosing a query output type" below)
7) Build a query string that you pass to the overpass client that makes requests to an Overpass API endpoint

The Overpass Query language enables diverse and powerful queries. This makes building a catch-all query builder quite difficult. For more complicated queries, you may need to create the query string directly:

```swift
let query = """
	data=[out:json];
	area["name"="Nürnberg"]->.nuremberg;
	(
	  node(area.nuremberg)["railway"="station"]["station"="subway"];
	)->.subway_stations;
	(
	  node(around.subway_stations:400)["amenity"="cinema"];
	  way(around.subway_stations:400)["amenity"="cinema"];
	  relation(around.subway_stations:400)["amenity"="cinema"];
	);

	out center;
	"""
```

This query finds all theaters less than 400 meters from any subway stop in nuremberg. To learn more about the Overpass Query Language, I recommend checking out out the [Overpass Language Guide](https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide#Recursing_up_and_down:_Completed_ways_and_relations), the [Overpass Query Language Wiki](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL), and [Overpass API by Example](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_API_by_Example). You can test overpass queries in your browser using [Overpass Turbo](https://overpass-turbo.eu/).

### **Choosing a query output type**

When using `OPQueryBuiler` you can choose from the following output types:

```swift
public enum OPQueryOutputType {
	case standard, center, geometry, recurseDown, recurseUp, recurseUpAndDown
	
	// The Overpass API language syntax for each output type
	func toString() -> String {
		switch self {
		case .standard:
			return "out;"
		case .recurseDown:
			return "(._;>;);out;"
		case .recurseUp:
			return "(._;<;);out;"
		case .recurseUpAndDown:
			return "((._;<;);>;);out;"
		case .geometry:
			return "out geom;"
		case .center:
			return "out center;"
		}
	}
}
```
- **Standard:** Basic output that does not fetch additional elements or geometry information
- **Recurse Down:** Enables full geometry reconstruction of query elements. Returns the queried elements plus:
	- all nodes that are part of a way which appears in the initial result set; plus
	- all nodes and ways that are members of a relation which appears in the initial result set; plus
	- all nodes that are part of a way which appears in the initial result set
- **Recurse Up:** Returns the queried elements plus:
	- all ways that have a node which appears in the initial result set
	- all relations that have a node or way which appears in the initial result set
	- all relations that have a way which appears in the result initial result set
- **Recurse Up and Down:** Recurse up then recurse down on the results of the upwards recursion
- **Geometry:** Returned elements full geometry information that is sufficient for visualization
- **Center:** Returned elements contain their center coordinate. Best/most efficient option when you don't want to visualize full element geometries. 

### **Making an Overpass request**

```swift
let client = OPClient() //1
client.endpoint = .kumiSystems //2

//3
do {
    let elements = try await client.fetchElements(query: query)
    print(elements) // Do something with the returned elements
} catch {
    print(error.localizedDescription)
}
```

1) Instantiate a client
2) Specify an endpoint: The free-to-use endpoints provided will typically be slower and may limit your usage. For better performance you can specify your own custom endpoint. 
3) Fetch elements: The decoded response will be in the form of a dictionary of Overpass elements keyed by their database id. The function is now async and uses modern Swift concurrency with try/catch error handling.

### **Generating MapKit Visualizations**

Generate visualizations for all elements the returned element dictionary:

```swift 
// Creates a dictionary of mapkit visualizations keyed by the corresponding element's id
let visualizations = OPVisualizationGenerator
	.mapKitVisualizations(forElements: elements)
```

Generate a visualization for an individual element:

```swift
if let visualization = OPVisualizationGenerator.mapKitVisualization(forElement: element) {
	// Do something
} else {
	print("Element doesn't have a geometry to visualize")
}
```

### **Displaying Visualizations via MKMapView**

**Step 1:** Add overlays and annotations to mapView using the included visualization generator

```swift
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
```

Depending on its case, a visualization can have one of the following associated values types:
1) `MKAnnotation`: For single coordinates. The title of the annotation is the value of the element's name tag.
2) `MKPolyline`: Commonly used for roads
3) `MKPolygon`: Commonly used for simple structures like buildings
4) `[MKPolyline]`: An array of related polylines in a collection such as a route or a waterway
5) `[MKPolygon]`: An array of related polygons that make up a more complicated structures. 

**Step 2:** Display views for the overlays and annotations

```swift
extension MapViewController: MKMapViewDelegate {
	// Delegate method for rendering overlays
	func mapView(
		_ mapView: MKMapView,
		rendererFor overlay: MKOverlay) -> MKOverlayRenderer
	{
		let strokeWidth: CGFloat = 2
		let strokeColor = UIColor.theme
		let fillColor = UIColor.theme.withAlphaComponent(0.5)
		
		if let polyline = overlay as? MKPolyline {
			let renderer = MKPolylineRenderer(
				polyline: polyline)
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		} else if let polygon = overlay as? MKPolygon {
			let renderer = MKPolygonRenderer(
				polygon: polygon)
			renderer.fillColor = fillColor
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		}	else if let multiPolyline = overlay as? MKMultiPolyline {
			let renderer = MKMultiPolylineRenderer(
				multiPolyline: multiPolyline)
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		} else if let multiPolygon = overlay as? MKMultiPolygon {
			let renderer = MKMultiPolygonRenderer(
				multiPolygon: multiPolygon)
			renderer.fillColor = fillColor
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		} else {
			return MKOverlayRenderer()
		}
	}

	/*
		// Make sure to add the following when configure your mapView:
		
		let markerReuseIdentifier = "MarkerAnnotationView"
		
		mapView.register(
			MKMarkerAnnotationView.self,
			forAnnotationViewWithReuseIdentifier: markerReuseIdentifier)
	*/
	
	// Delegate method for setting annotation views.
	func mapView(
		_ mapView: MKMapView,
		viewFor annotation: MKAnnotation) -> MKAnnotationView?
	{
		guard 
			let pointAnnotation = annotation as? MKPointAnnotation 
		else {
			return nil
		}
		
		let view = MKMarkerAnnotationView(
			annotation: pointAnnotation,
			reuseIdentifier: markerReuseIdentifier)
		
		view.markerTintColor = UIColor.theme
		return view
	}
}
```

### **Displaying Visualizations via SwiftUI Map**

To display Overpass API data in a SwiftUI Map view, you can use the following approach:

```swift
import SwiftUI
import MapKit
import SwiftOverpassAPI

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var elements: [Int: OPElement] = [:]
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                Text(annotation.title ?? "")
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(5)
            }
        }
        .overlay(overlays)
        .task {
            await fetchData()
        }
    }
    
    private var annotations: [MKPointAnnotation] {
        elements.values.compactMap { element in
            guard let visualization = OPVisualizationGenerator.mapKitVisualization(forElement: element),
                  case .annotation(let annotation) = visualization else {
                return nil
            }
            return annotation
        }
    }
    
    private var overlays: some View {
        GeometryReader { geometry in
            ForEach(elements.values.compactMap { element -> (Int, OPMapKitVisualization)? in
                guard let visualization = OPVisualizationGenerator.mapKitVisualization(forElement: element) else {
                    return nil
                }
                return (element.id, visualization)
            }, id: \.0) { _, visualization in
                switch visualization {
                case .polyline(let polyline):
                    MapPolyline(polyline: polyline)
                        .stroke(Color.blue, lineWidth: 2)
                case .polygon(let polygon):
                    MapPolygon(polygon: polygon)
                        .fill(Color.blue.opacity(0.3))
                        .stroke(Color.blue, lineWidth: 2)
                case .polylines(let polylines):
                    ForEach(polylines, id: \.self) { polyline in
                        MapPolyline(polyline: polyline)
                            .stroke(Color.blue, lineWidth: 2)
                    }
                case .polygons(let polygons):
                    ForEach(polygons, id: \.self) { polygon in
                        MapPolygon(polygon: polygon)
                            .fill(Color.blue.opacity(0.3))
                            .stroke(Color.blue, lineWidth: 2)
                    }
                case .annotation:
                    EmptyView()
                }
            }
        }
    }
    
    private func fetchData() async {
        let boundingBox = OPBoundingBox(region: region)
        let query = try? OPQueryBuilder()
            .setElementTypes([.node, .way, .relation])
            .setBoundingBox(boundingBox)
            .setOutputType(.geometry)
            .buildQueryString()
            
        guard let query = query else { return }
        
        let client = OPClient()
        client.endpoint = .kumiSystems
        
        do {
            elements = try await client.fetchElements(query: query)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// Helper views for rendering MapKit overlays in SwiftUI
struct MapPolyline: Shape {
    let polyline: MKPolyline
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = polyline.points()
        guard let firstPoint = points.first else { return path }
        
        path.move(to: firstPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

struct MapPolygon: Shape {
    let polygon: MKPolygon
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = polygon.points()
        guard let firstPoint = points.first else { return path }
        
        path.move(to: firstPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

## **Example App**
<p align="center">
    <img src="Screenshots/tourist_attractions.png?raw=true" alt="Nuremberg Tourism" width="250"> 
    <img src="Screenshots/subway.png?raw=true" alt="Nuremberg Subway Lines" width="250"> 
    <img src="Screenshots/subway_with_stops.png?raw=true" alt="Nuremberg Subway Lines with Stops" width="250"> 
    <img src="Screenshots/max_morlock.png?raw=true" alt="Bart Nuremberg Max-Morlock-Stadion" width="250"> 
</p>

To run the example project, clone the repo, and open the project in the SwiftOverpassAPIDemo directory.

## **Author**

v4ulthunt3r, peter.hildel@gmail.com

## **Aknowledgements**

Thanks to all those who contribute to Overpass API and OpenStreetMap. Thank you to [Edward Samson](https://github.com/tyrasd), whose [osmtogeojson](https://github.com/tyrasd/osmtogeojson) code made this even possible. 

## **License**

SwiftOverpassAPI is available under the MIT license. See the LICENSE file for more info.
