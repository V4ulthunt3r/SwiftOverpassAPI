import SwiftUI
import SwiftOverpassAPI

struct NodeDetailView: View {
    let node: OPNode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Location")) {
                    let coordinate = node.coordinate
                    Text("Latitude: \(coordinate.latitude)")
                    Text("Longitude: \(coordinate.longitude)")
                }
                
                Section(header: Text("Tags")) {
                    ForEach(Array(node.tags.keys.sorted()), id: \.self) { key in
                        if let value = node.tags[key] {
                            HStack {
                                Text(key)
                                    .font(.headline)
                                Spacer()
                                Text(value)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle(node.tags["name"] ?? "Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 