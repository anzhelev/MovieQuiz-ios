//
//  ArrayTests.swift
//  ArrayTests
//
//  Created by Andrey Zhelev on 11.01.2024.
//
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { // тест на успешное взятие элемента по индексу
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws { // тест на взятие элемента по неправильному индексу
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let value = array[safe: 6]
        
        // Then
        XCTAssertNil(value)
//        XCTAssertEqual(value, 2)
    }
}