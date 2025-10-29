//
//  CoreMediaError.swift
//  LezhinSnack
//
//  Created by lwc on 9/29/25.
//

import Foundation

public enum CoreMediaError:Error {
    
    static let domain = "CoreMediaErrorDomain"
    
    case unknown
    case notFound
    case unauthorized
    case authenticationError
    case forbidden
    case unavailable
    case mediaFileError
    case bandwidthExceeded
    case playlistUnchanged
    case decoderMalfunction
    case decoderTemporarilyUnavailable
    case wrongHostIP
    case wrongHostDNS
    case badURL
    case invalidRequest
    case unrecognizedHttpResponse
    
    init?(_ error:NSError){
        
        guard error.domain == CoreMediaError.domain else {return nil}
        
        switch error.code {
        case -12937:
            // HTTP: 401     -12937  CoreMediaErrorDomain    Authentication Error
            // HTTP: 407     -12937  CoreMediaErrorDomain    Authentication Error
            self = .authenticationError
        case -16840:
            self = .unauthorized
        case -12660:
            // HTTP: 403     -12660  CoreMediaErrorDomain    HTTP 403: Forbidden
            self = .forbidden
        case -12938:
            //HTTP: 404     -12938  CoreMediaErrorDomain    HTTP 404: File not found
            self = .notFound
        case -12661:
            //HTTP: 503     -12661  CoreMediaErrorDomain    HTTP 503: Unavailable
            self = .unavailable
        case -12645, -12889:
            //   if long .ts video file respons  -12645  CoreMediaErrorDomain    No response for media file in 10 s
            //   https://developer.apple.com/forums/thread/5589
            self = .mediaFileError
        case -12318:
            //  video .ts file bitrate differ from m3u8 declaration     -12318  CoreMediaErrorDomain    Segment exceeds specified bandwidth for variant
            self =  .bandwidthExceeded
        case -12642:
            //  for live stream.playlist m3u8 did not change too long   -12642  CoreMediaErrorDomain    Playlist File unchanged for 2 consecutive reads
            self =  .playlistUnchanged
        case -12911:
            self =  .decoderMalfunction
        case -12913:
            self =  .decoderTemporarilyUnavailable
        case -1004:
            //  if wrong host ip    -1004   kCFErrorDomainCFNetwork
            self =  .wrongHostIP
        case -1003:
            //   if wrong dns host name  -1003   kCFErrorDomainCFNetwork
            self =  .wrongHostDNS
        case -1000:
            //   if bad formatted URL    -1000   kCFErrorDomainCFNetwork
            self =  .badURL
        case -1202:
            //   if invalid https/ssl request    -1202   kCFErrorDomainCFNetwork
            self =  .invalidRequest
        case -12666:
            //400     -12666  CoreMediaErrorDomain    unrecognized http response 400
            //402     -12666  CoreMediaErrorDomain    unrecognized http response 402
            //405     -12666  CoreMediaErrorDomain    unrecognized http response 405
            //406     -12666  CoreMediaErrorDomain    unrecognized http response 406
            //409     -12666  CoreMediaErrorDomain    unrecognized http response 409
            //...
            //415     -12666  CoreMediaErrorDomain    unrecognized http response 415
            //500     -12666  CoreMediaErrorDomain    unrecognized http response 500
            //501     -12666  CoreMediaErrorDomain    unrecognized http response 501
            //502     -12666  CoreMediaErrorDomain    unrecognized http response 502
            //504     -12666  CoreMediaErrorDomain    unrecognized http response 504
            //505     -12666  CoreMediaErrorDomain    unrecognized http response 505
            self =  .unrecognizedHttpResponse
        default:
            self =  .unknown
        }
    }
}
