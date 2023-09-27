//
//  ClassifiedData.swift
//  PackingDensityMac
//
//  Created by weng chong lao on 10/04/2023.
//

import Foundation

class ClassifiedData {
    
    var identification: (Int, Int)
    var data: [(packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)]
    
    init(identification: (Int, Int), data: [(packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)]) {
        self.identification = identification
        self.data = data
    }
    
    
    func appendData(input: (packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)) {
        data.append(input)
        data.sort { $0.smallParticlesPercentage < $1.smallParticlesPercentage }
    }
}


class ClassifiedDataList {
    
    private var dataList = [ClassifiedData]()
    
    func appendData(data: (packingDensity: Float, bigParticlesPercentage: Float, smallParticlesPercentage: Float, ratioOfContainerBigParticle: Float, ratioOfBigParticleSmallParticle: Float)) {
        
        var count: Int = 0
        
        for classifiedData in dataList {
            if classifiedData.identification == (Int(data.ratioOfContainerBigParticle), Int(data.ratioOfBigParticleSmallParticle)) {
                classifiedData.appendData(input: data)
                break
            }
            count += 1
        }
        
        if count == dataList.count {
            dataList.append(ClassifiedData(identification: (Int(data.ratioOfContainerBigParticle), Int(data.ratioOfBigParticleSmallParticle)), data: [data]))
        }
    }
    
    
    func getAllData() -> [ClassifiedData] {
        return dataList
    }
}
