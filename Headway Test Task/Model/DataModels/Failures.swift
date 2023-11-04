//
// Created by Dmytro Kopanytsia on 04.11.2023.
//

import Foundation

enum DataFailure: Error, Equatable {
    case fileNotFound
    case fileNotLoaded
    case imageNotFound
    case imageDataCorrupted
    case booksNotFound
}

enum PlayingFailure: Error, Equatable {
    case playerNotLoaded
    case outOfDurationRange
    case durationMismatch
}

enum PurchaseFailure: Error, Equatable {
    case productNotFound
    case purchaseUnverified(Error)
    case purchaseFailed
    case purchaseCancelled
    case purchasePending
    case unknownPurchaseResult
    
    var localizedDescription: String {
        switch self {
        case .productNotFound:
            return "Product not found"
        case .purchaseUnverified(let error):
            return "Purchase unverified: \(error.localizedDescription)"
        case .purchaseFailed:
            return "Purchase failed"
        case .purchaseCancelled:
            return "Purchase cancelled"
        case .purchasePending:
            return "Purchase pending"
        case .unknownPurchaseResult:
            return "Unknown purchase result"
        }
    }
    
    static func ==(lhs: PurchaseFailure, rhs: PurchaseFailure) -> Bool {
        switch (lhs, rhs) {
        case (.productNotFound, .productNotFound), (.purchaseFailed, .purchaseFailed), (.purchaseCancelled, .purchaseCancelled), (.purchasePending, .purchasePending), (.unknownPurchaseResult, .unknownPurchaseResult):
            return true
        case (.purchaseUnverified(let lhsError), .purchaseUnverified(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}