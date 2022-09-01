//
//  WeatherForecastBrickUnitTests.swift
//  WeatherForecastBrickUnitTests
//
//  Created by Dmytro Ivanchuk on 30.08.2022.
//

import XCTest
import CoreLocation
@testable import WeatherForecastBrick

class WeatherForecastBrickUnitTests: XCTestCase {
    var sut: WeatherManager!
    
    // custom urlsession for mock network calls
    var mockURLSession: URLSession!
    
    // set required mock parameters
    let testLatitude: CLLocationDegrees = 48.94104282318168
    let testLongitude: CLLocationDegrees = 24.74946079122298

    override func setUpWithError() throws {
        // Set url session for mock networking
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: configuration)
        
        // WeatherManager, injected with custom url session for mocking
        sut = WeatherManager(urlSession: mockURLSession)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockURLSession = nil
    }
    
    private func generateMockData(isValidData: Bool) -> Data {
        // generate data representation of valid or invalid .json file, based on test requirements
        guard let filePathString = Bundle(for: type(of: self)).path(forResource: "api\(isValidData ? "Valid" : "Invalid")WeatherData", ofType: "json") else {
            fatalError(".json file is not found.")
        }
        guard let json = try? String(contentsOfFile: filePathString, encoding: .utf8) else {
            fatalError("Unable to convert .json file to String.")
        }

        return json.data(using: .utf8)!
    }
    
    
    func test_fetchWeather_withValidJSON_shouldFetchExpectedWeatherData() throws {
        // Return data in mock request handler
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), self.generateMockData(isValidData: true))
        }
        
        // set expected results to assert
        let expectedConditionId = 803
        let expectedCondition = "broken clouds"
        let expectedTemperature = 28.78
        let expectedwindSpeed = 4.26
        let expectedCountryCode = "UA"
        let expectedCityName = "Ivano-Frankivsk"
        
        let expectation = XCTestExpectation(description: "Fetch expected weather data")
        
        // Make mock api network request to fetch weather data
        sut.fetchWeather(latitude: testLatitude, longitude: testLongitude) { weatherModel in
            XCTAssertEqual(weatherModel?.conditionId, expectedConditionId)
            XCTAssertEqual(weatherModel?.condition, expectedCondition)
            XCTAssertEqual(weatherModel?.temperature, expectedTemperature)
            XCTAssertEqual(weatherModel?.windSpeed, expectedwindSpeed)
            XCTAssertEqual(weatherModel?.countryCode, expectedCountryCode)
            XCTAssertEqual(weatherModel?.cityName, expectedCityName)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchWeather_withInvalidJSON_shouldFailFetchingExpectedWeatherData() throws {
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), self.generateMockData(isValidData: false))
        }
        
        let expectation = XCTestExpectation(description: "Fail fetching expected weather data")
        
        sut.fetchWeather(latitude: testLatitude, longitude: testLongitude) { weatherModel in
            XCTAssertNil(weatherModel)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchWeather_withValidJSONAndURLSessionError_shouldFailFetchingExpectedWeatherData() throws {
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(), self.generateMockData(isValidData: true))
        }
        MockURLProtocol.error = MockURLProtocolError.error
        
        let expectation = XCTestExpectation(description: "Fail fetching expected weather data")
        
        sut.fetchWeather(latitude: testLatitude, longitude: testLongitude) { weatherModel in
            XCTAssertNil(weatherModel)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
