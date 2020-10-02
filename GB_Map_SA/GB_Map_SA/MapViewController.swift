//
//  MapViewController.swift
//  GB_Map_SA
//
//  Created by Aleksandr Serov on 28.09.2020.
//  Copyright © 2020 Aleksandr Serov. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    //MARK:- Properties
    
    //Координаты центра Санкт-Петербурга
    private let coordinate = CLLocationCoordinate2D(latitude: 59.9421696, longitude: 30.3160677)
    private var marker: GMSMarker?
    private var manualMarker: GMSMarker?
    private var locationManager: CLLocationManager?
    private var locations: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configurateLocationManager()
    }
    
    //MARK:- Func
    private func configureMap() {
        mapView.delegate = self
        // Создаём камеру с использованием координат и уровнем увеличения
        let camera = GMSCameraPosition(target: coordinate, zoom: 15)
        // Устанавливаем камеру для карты
        mapView.camera = camera
        mapView.isTrafficEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    private func configurateLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
//        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()
        
    }
    // Установка и удалние маркера
    private func toggleMarker() {
        if marker == nil {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            self.marker = marker
        } else {
            marker?.map = nil
            marker = nil
        }
    }
    
    private func addMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.map = mapView
        self.marker = marker
    }
    
    
    //MARK:- Actions
    @IBAction func updateLocationAction(_ sender: Any) {
        locationManager?.startUpdatingLocation()
        guard let location = self.locations else { return }
        mapView.animate(toLocation: location.coordinate )
    }
    
}
//MARK:- Extensions

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let manualMarker = manualMarker {
            manualMarker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            self.manualMarker = marker
        }
    }
    // Обработка нажатия кнопки "Моя локация"
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        locationManager?.requestLocation()
        guard let location = self.locations else { return false }
        mapView.animate(toLocation: location.coordinate )
        return true
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations = locations.first
        addMarker(position: locations.first!.coordinate)
        guard let location = self.locations else { return }
        mapView.animate(toLocation: location.coordinate )
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

