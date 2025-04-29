import SwiftUI
import SwiftOverpassAPI
import MapKit
import CoreLocation

struct ContentView: View {
    @State private var selectedQuery: QueryOption?
    @State private var searchResults: [OPNode] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedNode: OPNode?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var mapViewModel = OverpassMapViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Query Selection
                Picker("Select Query", selection: $selectedQuery) {
                    Text("Select a query").tag(nil as QueryOption?)
                    ForEach(QueryOption.options) { option in
                        Text(option.title).tag(option as QueryOption?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(Color.purple)
                .padding()
                
                // Map View
                ZStack {
                    OverpassMapView(region: $region, viewModel: mapViewModel)
                        .edgesIgnoringSafeArea(.all)
                        .onReceive(mapViewModel.$region) { newRegion in
                            if let query = selectedQuery, let region = newRegion {
                                performSearch(with: query, region: region)
                            }
                        }
                    
                    // Location Button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: centerOnUserLocation) {
                                Image(systemName: "location.fill")
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                    }
                }
                
                // Results List
                VStack{
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if !searchResults.isEmpty {
                        List(searchResults) { element in
                            if let title = element.tags["name"] {
                                VStack(alignment: .leading) {
                                    Text(title)
                                        .font(.headline)
                                    if let type = element.tags["amenity"] {
                                        Text(type)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .onTapGesture {
                                    selectedNode = element
                                    withAnimation {
                                        region.center = element.coordinate
                                        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    }
                                }
                            }

                        }
                    }
                }
                //.frame(maxHeight: 200)

            }
            .navigationTitle("Overpass API Demo")
            .sheet(item: $selectedNode) { node in
                NodeDetailView(node: node)
            }
            .onChange(of: selectedQuery) { oldValue, newValue in
                if let query = newValue {
                    // Update region to match the query's default region
                    region = query.defaultRegion
                    performSearch(with: query, region: query.defaultRegion)
                }
            }
        }
    }
    
    private func performSearch(with queryOption: QueryOption, region: MKCoordinateRegion) {
        isLoading = true
        errorMessage = nil
        
        Task {
            let queryString = queryOption.queryGenerator(region)
            let overpass = OPClient()
            
            do {
                var elements = try await overpass.fetchElements(query: queryString)
                print("Received \(elements.count) elements")
                
                // Filter for nodes only
                searchResults = elements.compactMap { element in
                    guard let node = element.value as? OPNode else { return nil }
                    if node.tags["name"] == nil {
                        elements.removeValue(forKey: element.key)
                        return nil
                    }
                    return node
                }
                print("Converted to \(searchResults.count) nodes")
                
                
                // Convert elements to visualizations using OPVisualizationGenerator
                let visualizations = OPVisualizationGenerator.mapKitVisualizations(forElements: elements)
                print("Created \(visualizations.count) visualizations")
                mapViewModel.addVisualizations(visualizations)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation {
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
        }
    }
}

#Preview {
    ContentView()
}
