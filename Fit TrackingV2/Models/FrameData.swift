//
//  FrameData.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 13/05/25.
//

import Foundation

struct FrameData:Codable{
    let timestamp: Int
    let keypoints: [Keypoints]
}
