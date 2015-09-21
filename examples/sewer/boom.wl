/*
 * boom.wl - routines for working with Boom special effects
 *
 * so far just water* for managing deep water effects
 *
 * XXX: Things to fix:
     * de-duplicate control sectors (need to build a map
       data structure)
 */

#"standard.h"

main {
    waterinit(-16, "FWATER1", "WATERMAP", 80)
    movestep(0,64) -- out of the way of control sectors
    pushpop(movestep(32,32) thing)

    -- a ramp of rooms, descending in floor and ceiling height
    fori(0, 7,
        water(
            room(sub(0, mul(i,24)), 200, 256, 256),
            sub(0, mul(i,24)),
            add(128,sub(0, mul(i,24)))
        )
        movestep(-256,0)
    )
}

-- simplified box, ceil is floor + 128
room(f,l,x,y) {
    box(f, add(128,f), l, x, y)
}

/*
 * waterinit - this should be called only once and before using any
 * other water* routines.
 *
 * the water routines will draw control sectors forward and to the right
 * of the pen location when this is called.
 */
waterinit(h, f, m, l) {
    set("water",     h) -- height of the water
    set("waterflat", f) -- what flat to use e.g. FWATER1
    set("watermap",  m) -- COLORMAP to use for underwater e.g. WATERMAP
    set("waterlight",l) -- how bright it is underwater

    set("watertag", newtag)
    !water -- where the next control sector will go

    -- define a texture matching the colormap. This is a hack so that
    -- the wad doesn't crash vanilla.
    texture(m,64,128)
    addpatch("BODIES",0,0)
}

/*
 * water - wrapper to use around functions which create sectors that should
 * have water in them.
 */
water(x, floorheight, ceilheight) {
    -- we only want to set the floor of *this* sector to waterflat if the
    -- water level is above the floor. (TODO: consider moving water.)
    lessthaneq(floorheight, get("water"))
      ?
        !notwater

        -- the control sector
        ^water
          ceil(get("waterflat"))
          move(8)
          triple(left(8))
          linetype(242, get("watertag") ) left(8)
          bot(get("watermap"))
          leftsector(get("water"), ceilheight, 140)
          linetype(0,0)
          move(16)
        !water

        -- decorate whatever we've been passed
        ^notwater
        sectortype(0, get("watertag") )
        floor(get("waterflat"))
        x
        sectortype(0,0)
        set("watertag", newtag)

      -- pass-through if no decoration necessary
      : x
}