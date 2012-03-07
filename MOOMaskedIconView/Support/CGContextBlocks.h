/**
 * CGContextBlocks.h
 *
 * Block-based convenience methods for organizing Core Graphics-heavy code.
 * 
 * See https://gist.github.com/gists/1988678 for the latest version.
 *
 * Idea stolen from http://www.natestedman.com/post/improving-cgcontext-with-blocks/
 */

typedef void(^CGStateBlock)();

void CGContextState(CGContextRef ctx, CGStateBlock actions)
{
    CGContextSaveGState(ctx);
    actions();
    CGContextRestoreGState(ctx);
}

void CGContextTransparencyLayer(CGContextRef ctx, CGStateBlock actions)
{
    CGContextBeginTransparencyLayer(ctx, NULL);
    actions();
    CGContextEndTransparencyLayer(ctx);
}

// End CGContextBlocks.h //