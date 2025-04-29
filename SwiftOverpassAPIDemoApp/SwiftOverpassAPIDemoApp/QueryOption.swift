import Foundation
import MapKit
import SwiftOverpassAPI

struct QueryOption: Identifiable {
    let id = UUID()
    let title: String
    let queryGenerator: (MKCoordinateRegion) -> String
    let defaultRegion: MKCoordinateRegion
    
    static let options: [QueryOption] = [
        QueryOption(
            title: "Hotels in Nuremberg",
            queryGenerator: { region in
                let boundingBox = OPBoundingBox(region: region)
                return try! OPQueryBuilder()
                    .setElementTypes([.node, .way, .relation])
                    .addTagFilter(key: "tourism", value: "hotel")
                    .setBoundingBox(boundingBox)
                    .setOutputType(.center)
                    .buildQueryString()
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
        ),
        QueryOption(
            title: "Tourist Attractions in Nuremberg",
            queryGenerator: { region in
                let boundingBox = OPBoundingBox(region: region)
                return try! OPQueryBuilder()
                    .setTimeOut(180)
                    .setElementTypes([.node, .way, .relation])
                    .addTagFilter(key: "tourism")
                    .setBoundingBox(boundingBox)
                    .setOutputType(.center)
                    .buildQueryString()
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
        ),
        QueryOption(
            title: "Nuremberg Subway Lines",
            queryGenerator: { region in
                let boundingBox = OPBoundingBox(region: region)
                return try! OPQueryBuilder()
                    .setTimeOut(180)
                    .setElementTypes([.relation, .way])
                    .addTagFilter(key: "railway", value: "subway")
                    .setBoundingBox(boundingBox)
                    .setOutputType(.geometry)
                    .buildQueryString()
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
                latitudinalMeters: 20000,
                longitudinalMeters: 20000
            )
        ),
        QueryOption(
            title: "Nuremberg Subway Lines with Stops",
            queryGenerator: { region in
                let boundingBox = OPBoundingBox(region: region)
                return try! OPQueryBuilder()
                    .setTimeOut(180)
                    .setElementTypes([.node, .relation, .way])
                    .addTagFilter(key: "railway", value: "station")
                    .addTagFilter(key: "station", value: "subway")
                    .setBoundingBox(boundingBox)
                    .setOutputType(.recurseUpAndDown)
                    .buildQueryString()
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
                latitudinalMeters: 20000,
                longitudinalMeters: 20000
            )
        ),
        QueryOption(
            title: "Theaters near subway Stops",
            queryGenerator: { region in
                return """
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
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
        ),
        QueryOption(
            title: "Max-Morlock-Stadion",
            queryGenerator: { region in
                let boundingBox = OPBoundingBox(region: region)
                return try! OPQueryBuilder()
                    .setTimeOut(180)
                    .setElementTypes([.relation, .way])
                    .addTagFilter(key: "name", value: "Max-Morlock-Stadion")
                    .setBoundingBox(boundingBox)
                    .setOutputType(.geometry)
                    .buildQueryString()
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.4263952, longitude: 11.1246614),
                latitudinalMeters: 500,
                longitudinalMeters: 500
            )
        ),
        QueryOption(
            title: "Biergarten",
            queryGenerator: { region in
                let boundingBox = OPBoundingBox(region: region)
                return try! OPQueryBuilder()
                    .setTimeOut(180)
                    .setElementTypes([.node])
                    .addTagFilter(key: "amenity", value: "biergarten")
                    .addTagFilter(key: "name")
                    .setBoundingBox(boundingBox)
                    .setOutputType(.center)
                    .buildQueryString()
            },
            defaultRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.450103, longitude: 11.075683),
                latitudinalMeters: 15000,
                longitudinalMeters: 15000
            )
        )
    ]
}

extension QueryOption: Equatable {
    static func == (lhs: QueryOption, rhs: QueryOption) -> Bool {
        return lhs.id == rhs.id
    }
}

extension QueryOption: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
