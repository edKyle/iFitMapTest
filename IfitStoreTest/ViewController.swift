//
//  ViewController.swift
//  IfitStoreTest
//
//  Created by Kyle on 7/5/16.
//  Copyright © 2016 Alphacamp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var Map: MKMapView!
    let locationManager = CLLocationManager()
    
    var ifitStoreArray = [["iFit shop":"1","lat":"25.116473","long":"121.509762"],
                          ["iFit shop":"2","lat":"24.957446","long":"121.537943"],
                          ["iFit shop":"3","lat":"25.009913","long":"121.513911"],
                          ["iFit shop":"4","lat":"25.002921","long":"121.514980"],
                          ["iFit shop":"5","lat":"25.062902","long":"121.575896"],
                          ["iFit shop":"6","lat":"25.059057","long":"121.511341"],
                          ["iFit shop":"7","lat":"24.981403","long":"121.315387"]]
    
    var userPlace:CLLocationCoordinate2D?
    var howFardistance:CLLocationDistance?
    var shortPolyLine:MKPolyline?
    
    var sourceMapItem : MKMapItem?
    var destinationMapItem : MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Map.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        
        // 放店家位置在地圖上
        for data in ifitStoreArray{
            
            let annotation = MKPointAnnotation()
            annotation.title = data["iFit shop"]
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(data["lat"]!)!,longitude: Double(data["long"]!)!)
            
            self.Map.addAnnotation(annotation)
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.Map.showAnnotations(self.Map.annotations, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //把頭針換成圖片
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "SpotPin"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var annotationView:MKAnnotationView? = Map.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKAnnotationView!
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
  
    // Place image on annotation view
            annotationView?.image = UIImage(named: "1")
            
        }
        return annotationView
    }
    
    // 點圖片產生行動
        func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: true)
    
            let tapStore = view.annotation as! MKPointAnnotation
            
//            beginEnd(userPlace!, endPlace: tapStore)
            
            for data in ifitStoreArray{
                if data["iFit shop"] == tapStore.title{
            
            tapBeginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: Double(data["lat"]!)!,longitude: Double(data["long"]!)!))
                    
            }
        }
    }
    
    // 放置使用者位置
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty == false {
            
            let userLocation = locations.first
            
            // delta: the range of latitude/longitude
            let latDelta: CLLocationDegrees = 0.05
            let lonDelta: CLLocationDegrees = 0.05
            
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let location: CLLocationCoordinate2D = (userLocation?.coordinate)!
            
            let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            
            self.Map.setRegion(region, animated: true)
            self.Map.showsUserLocation = true
            
            userPlace = location
            
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 25.116473,longitude: 121.509762))
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 24.957446,longitude: 121.537943))
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 25.009913,longitude: 121.513911))
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 25.002921,longitude: 121.514980))
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 25.062902,longitude: 121.575896))
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 25.059057,longitude: 121.511341))
            beginEnd(userPlace!, endPlace: CLLocationCoordinate2D(latitude: 24.981403,longitude: 121.315387))
            
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
//第一次產生poly line
    func loadDirectionRoute(sourceMapItem:MKMapItem, destinationMapItem:MKMapItem, withTransportType transporType: MKDirectionsTransportType) {
    
        //instance DirectionRequest data
        let directionsRequest : MKDirectionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.requestsAlternateRoutes = false
        //   directionsRequest.transportType = transporType
        
        // 傳入data開始計算
        let directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) in
            
            if error == nil {
                
                if response?.routes.isEmpty == false {
                    
                    // 判斷最短路徑 Add over layes
                    for route: MKRoute in (response?.routes)! {
                    
                        if self.howFardistance == nil || self.howFardistance > route.distance{
                            self.howFardistance = route.distance
                            self.shortPolyLine = route.polyline
                            
                            self.Map.removeOverlays(self.Map.overlays)
                        
                            self.Map.addOverlay(self.shortPolyLine!, level: MKOverlayLevel.AboveRoads)
                        
                        }
                    }
                }
            }
        }
    }
    
//點圖片之後產生新的poly line
    func loadDirectionRoute2(sourceMapItem:MKMapItem, destinationMapItem:MKMapItem, withTransportType transporType: MKDirectionsTransportType) {
        
        //instance DirectionRequest data
        let directionsRequest : MKDirectionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.requestsAlternateRoutes = false
        //   directionsRequest.transportType = transporType
        
        // 傳入data開始計算
        let directions = MKDirections(request: directionsRequest)
        directions.calculateDirectionsWithCompletionHandler { (response:MKDirectionsResponse?, error:NSError?) in
            
            if error == nil {
                
                if response?.routes.isEmpty == false {
                    
                    for route: MKRoute in (response?.routes)! {
                            
                            self.Map.removeOverlays(self.Map.overlays)
                            self.Map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                            
                        }
                    }
                }
            }
        }
    

    
    // 將poly line 放入 overlay
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red:0.251,  green:0.471,  blue:0.753, alpha:1)
            polylineRenderer.lineWidth = 5
            
            return polylineRenderer
        }
        return MKPolygonRenderer()
    }
    
    // 設兩點 use 產生 poly line func
    func beginEnd(userPlace:CLLocationCoordinate2D, endPlace:CLLocationCoordinate2D){
        
            sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate:userPlace, addressDictionary: nil))
            destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate:endPlace, addressDictionary: nil))
            self.loadDirectionRoute(self.sourceMapItem!, destinationMapItem: self.destinationMapItem!, withTransportType: .Walking)
    }
    
    func tapBeginEnd(userPlace:CLLocationCoordinate2D, endPlace:CLLocationCoordinate2D){
    
        sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate:userPlace, addressDictionary: nil))
        destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate:endPlace, addressDictionary: nil))
        self.loadDirectionRoute2(self.sourceMapItem!, destinationMapItem: self.destinationMapItem!, withTransportType: .Walking)
    
    }
}



