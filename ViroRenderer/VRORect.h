//
//  VRORect.h
//  ViroRenderer
//
//  Created by Raj Advani on 10/15/15.
//  Copyright © 2015 Viro Media. All rights reserved.
//

#ifndef VRORect_h
#define VRORect_h

#include "VROSize.h"
#include "VROPoint.h"

class VRORect {
    
public:
    
    VROPoint origin;
    VROSize size;
    
    VRORect()
    {}
    
    VRORect(VROPoint origin, VROSize size) :
        origin(origin),
        size(size)
    {}
    
};

VRORect VRORectMake(float x, float y, float width, float height);

#endif /* VRORect_h */
