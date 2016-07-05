//
// Created by Werner Altewischer on 04/07/16.
//

#ifndef WEBBCODECOMMONDEFINITIONS_H

#define WEBBCODECOMMONDEFINITIONS_H

#define WE_SET_BIT(x, y) { x |= y; }
#define WE_UNSET_BIT(x, y) { x &= ~y; }
#define WE_CONTAINS_BIT(x, y) ((x & y) == y)
#define WE_NOT_CONTAINS_BIT(x, y) ((x & y) != y)
#define WE_DISPATCH_ONCE(dispatchBlock) ({static dispatch_once_t token; dispatch_once(&token, dispatchBlock);})

#endif