//
//  WeatherTableViewCell.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 20/6/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func draw(weather:InstantWeather)  {
        cityLabel.text = weather.name
        descriptionLabel.text = weather.description
        temperatureLabel.text = "\(weather.temp)K"
        pressureLabel.text = "\(weather.pressure)hPa"
        humidityLabel.text = "\(weather.humidity)%"
        windSpeedLabel.text = "\(weather.windSpeed)m/s"
    }
    
}
