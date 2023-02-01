// SBTNetworkTestViewController.swift
//
// Copyright (C) 2016 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import CoreLocation

class SBTExtensionCoreLocationViewController: UIViewController, CLLocationManagerDelegate {

    private let authorizationButton = UIButton()
    private let updateLocationButton = UIButton()
    private let stopLocationUpdateButton = UIButton()
    private let statusLabel = UILabel()
    private let locationLabel = UILabel()
    private let threadLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        statusLabel.text = "-"
        statusLabel.accessibilityIdentifier = "location_status"

        locationLabel.text = "-"
        locationLabel.accessibilityIdentifier = "location_pos"

        threadLabel.text = "-"
        threadLabel.accessibilityIdentifier = "location_thread"

        authorizationButton.setTitle("Authorization status", for: .normal)
        updateLocationButton.setTitle("Update location", for: .normal)
        stopLocationUpdateButton.setTitle("Stop location updates", for: .normal)

        [authorizationButton, updateLocationButton, stopLocationUpdateButton].forEach {
            $0.setTitleColor(.systemBlue, for: .normal)
            $0.setTitleColor(.systemRed, for: .highlighted)
        }

        authorizationButton.addTarget(self, action: #selector(authorizationStatusTapped), for: .touchUpInside)
        updateLocationButton.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)
        stopLocationUpdateButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        let statusStack = UIStackView(arrangedSubviews: [authorizationButton, statusLabel])
        let locationStack = UIStackView(arrangedSubviews: [updateLocationButton, stopLocationUpdateButton, locationLabel, threadLabel])
        let contentStack = UIStackView(arrangedSubviews: [statusStack, locationStack])

        [statusStack, locationStack, contentStack].forEach {
            $0.axis = .vertical
            $0.spacing = 16
        }
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    @objc func updateTapped(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }

    @objc func stopTapped(_ sender: Any) {
        locationManager.stopUpdatingLocation()
    }

    @objc func authorizationStatusTapped(_ sender: Any) {
        statusLabel.text = "\(CLLocationManager.authorizationStatus().rawValue)"
    }
}

extension SBTExtensionCoreLocationViewController {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let threadName = Thread.isMainThread ? "Main" : "Not main"
        DispatchQueue.main.async { [weak self] in
            self?.locationLabel.text = locations.map { "\($0.coordinate.latitude) \($0.coordinate.longitude)" }.joined(separator: "+")
            self?.threadLabel.text = threadName
        }
    }
}
