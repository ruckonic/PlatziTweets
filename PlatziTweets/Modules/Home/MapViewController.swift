//
//  MapViewController.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/15/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
// MARK: - Outlets
    @IBOutlet weak var mapContainerView: UIView!
// MARK: -Properties
    public var posts = [Post]()
    private var map: MKMapView?
// MARK: - Actions
// MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupMap()
        self.setupMarkers()
    }
// MARK: - Actions
// MARK: - Methods
    private func setupMap() {
        map = MKMapView(frame: mapContainerView.bounds)
        mapContainerView.addSubview(map ?? UIView())
    }
    
    private func setupMarkers() {
        posts.forEach { (item) in
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
            marker.title = item.text
            marker.subtitle = item.author.names
            
            map?.addAnnotation(marker)
        }
        
        // Buscando la ultima localizacion del arreglo
        guard let lastPost = posts.last else {
            return
        }
        
        let lastPostLocation = CLLocationCoordinate2D(latitude: lastPost.location.latitude, longitude: lastPost.location.longitude)
        
        guard let heading = CLLocationDirection(exactly: 32) else {
            return
        }
        map?.camera = MKMapCamera(lookingAtCenter: lastPostLocation, fromDistance: 30, pitch: .zero, heading: heading)
    }

}
