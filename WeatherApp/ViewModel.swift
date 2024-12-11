//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Vladyslav Pryl on 11.12.2024.
//

import SwiftUI
import OpenMeteoSdk

class WeatherWM: ObservableObject{
    @Published var week: [OneDay] = []
    
    init() {
        let latitude = "59.334591"
        let longitude = "18.063240"
        let url = "https://api.open-meteo.com/v1/forecast?latitude="+latitude+"&longitude="+longitude+"&current=temperature_2m,weather_code&hourly=temperature_2m,precipitation&daily=temperature_2m_min,temperature_2m_max,weather_code&timezone=auto&format=flatbuffers"
        Task {
            let data = try await Self.getData(url)
            week = Self.convertDataToWeek(data)
            largeInfo = LargeInformation(temperature: Int(data.current.temperature2m),
                                         location: "Stockholm",
                                         weatherCode: Int(data.current.weatherCode))
        }
    }
    
    var largeInfo: LargeInformation = LargeInformation() {
        didSet {
            objectWillChange.send()
        }
    }
    
    var firstGradient: Color {
        switch Self.codeToImg(largeInfo.weatherCode) {
        case "cloud.fog.fill":
                .fog
        case "snow":
                .cyan
        case "cloud.rain.fill", "cloud.heavyrain.fill", "cloud.bolt.rain.fill":
                .purplue
        case "cloud.drizzle.fill":
                .gray
        default:
                .blue
        }
    }
    
    static private func getCalendar() -> Calendar {
        Calendar(identifier: Calendar.Identifier.gregorian)
    }
    
    static func getData(_ openMeteo: String) async throws -> WeatherData {
        let url = URL(string: openMeteo )!
        let responses = try await WeatherApiResponse.fetch(url: url)
        let response = responses[0]
        
        let utcOffsetSeconds = response.utcOffsetSeconds
//        let timezone = response.timezone
//        let timezoneAbbreviation = response.timezoneAbbreviation
//        let latitude = response.latitude
//        let longitude = response.longitude
        
        let current = response.current!
        let hourly = response.hourly!
        let daily = response.daily!
        
        return WeatherData(
            current: .init (
                time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
                temperature2m: current.variables(at: 0)!.value,
                weatherCode: current.variables(at: 1)!.value
            ),
            hourly: .init(
                time: hourly.getDateTime(offset: utcOffsetSeconds),
                temperature2m: hourly.variables(at: 0)!.values,
                precipitation: hourly.variables(at: 1)!.values
            ),
            daily: .init(
                time: daily.getDateTime(offset: utcOffsetSeconds),
                temperature2mMax: daily.variables(at: 0)!.values,
                temperature2mMin: daily.variables(at: 1)!.values,
                weatherCode: daily.variables(at: 2)!.values
            )
        )
    }
    
    static func convertDataToWeek(_ data: WeatherData) -> [OneDay] {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .gmt
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

//        for (i, date) in data.hourly.time.enumerated() {
//          print(dateFormatter.string(from: date))
//          print(data.hourly.temperature2m[i])
//          print(data.hourly.precipitation[i])
//        }
        
        var weekArray: [OneDay] = []
        
        for (i, date) in data.daily.time.enumerated() {
//          print(dateFormatter.string(from: date))
//          print(data.daily.temperature2mMin[i])
//          print(data.daily.temperature2mMax[i])
            let day = getCalendar().dateComponents([.weekday, .weekdayOrdinal], from: date)
            let tmpr = (Int(data.daily.temperature2mMin[i]) + Int(data.daily.temperature2mMax[i])) / 2
            weekArray.append(.init(dayPointer: day.weekday!-1, temperature: tmpr,
                                   weatherCode: Int(data.daily.weatherCode[i]))
            )
        }
        return weekArray
    }
    
    static func codeToImg(_ i: Int) -> String {
        switch i {
        case 0:
            return "sun.max.fill"
        case 1,2,3:
            return "cloud.sun.fill"
        case 45,48:
            return "cloud.fog.fill"
        case 51, 53, 55, 56, 57:
            return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67:
            return "cloud.rain.fill"
        case 71, 73, 75, 77:
            return "snow"
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
        default:
            return "cloud.bolt.rain.fill"
        }
    }
    
    static func printImgIcon(_ sysName: String, size: CGFloat) -> some View {
        Image(systemName: sysName)
            .symbolRenderingMode(.multicolor)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
    
    static func printTemperature(_ tmp: Int, fontSize: CGFloat) -> some View {
        Text(" \(tmp)°")
            .font(.system(size: fontSize, weight: .medium))
            .foregroundStyle(.white)
    }
    
    static func printLocation(name: String, size: CGFloat) -> some View {
        Text(name)
            .font(.system(size: size))
            .foregroundStyle(.white)
    }
    
    struct LargeInformation {
        let temperature: Int
        let location: String
        let weatherCode: Int
        
        init(temperature: Int? = 3, location: String? = "Earth", weatherCode: Int? = 0) {
            self.temperature = temperature!
            self.location = location!
            self.weatherCode = weatherCode!
        }
    }
    
    struct OneDay: Identifiable {
        let dayPointer: Int
        let temperature: Int
        let weatherCode: Int
        var id = UUID()
        
        var dayOfWeek: String {
            getCalendar().shortWeekdaySymbols[dayPointer]
        }
    }
    
    struct WeatherData {
        let current: Current
        let hourly: Hourly
        let daily: Daily
        
        struct Current {
            let time: Date
            let temperature2m: Float
            let weatherCode: Float
        }
        struct Hourly {
            let time: [Date]
            let temperature2m: [Float]
            let precipitation: [Float]
        }
        struct Daily {
            let time: [Date]
            let temperature2mMax: [Float]
            let temperature2mMin: [Float]
            let weatherCode: [Float]
        }
    }
}
