//
//  MapPointsViewController.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapPointsViewController: UIViewController {
    
    var postController: PostController?

    
    @IBOutlet weak var map: MKMapView!
    

   private let annotationReuseIdentifier = "PostAnnotationView"
        private var posts: [Post] = [] {
            didSet {
                let oldPosts = Set(oldValue)
                let newPosts = Set(self.posts)
                let addedPosts = Array(newPosts.subtracting(oldPosts))
                let removedPosts = Array(oldPosts.subtracting(newPosts))
                map.removeAnnotations(removedPosts)
                map.addAnnotations(addedPosts)
                map.showAnnotations(self.posts, animated: true)
            }
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.map.showsUserLocation = true
            self.map.delegate = self
            self.map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationReuseIdentifier)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let posts = self.postController?.posts {
                self.posts = posts.filter { $0.geotag != nil }
            }

        }
    }

    extension MapPointsViewController: MKMapViewDelegate {
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let post = annotation as? Post else { return nil }
            
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationReuseIdentifier, for: post) as? MKMarkerAnnotationView else {
                fatalError("Missing registered map annotation view")
            }
            
            annotationView.canShowCallout = true
            annotationView.animatesWhenAdded = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let post = view.annotation as? Post else { return }
            
            // self.performSegue(withIdentifier: "DetailSegue", sender: post)
        }
    


}
