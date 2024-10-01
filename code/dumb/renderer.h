#ifndef RENDERER_H
#define RENDERER_H

// This might be the worst software renderer ever

typedef struct Bitmap {
    u32 *pixels;
    u32 width, height;
} Bitmap;

typedef struct Cam_2D {
    Vec2 pos;
    f32 scale;
} Cam_2D;

//- @note: Fundementals
function Bitmap* r_get_framebuffer(void);
function void r_test_gradient(void);
function void r_put_pixel_at(Vec2 p, Color c);
function void r_clear(void);
function void r_clear_color(Color c);

//- @note: Primatives
function void r_draw_circle(Vec2 p, f32 r, Color c);
function void r_draw_line(Vec2 p0, Vec2 p1, Color c);
function void r_draw_vert(f32 x, f32 y0, f32 y1, Color c);
function void r_draw_quad_framef(f32 x0, f32 y0, f32 x1, f32 y1, Color c);
function void r_draw_quad_frame(Vec2 p0, Vec2 p1, Vec2 p2, Vec2 p3, Color c);
function void r_draw_rect(Vec2 p, Vec2 sz, Color c);

//- @note: Game specific functionality
function void r_scene(Entity cam, Border *walls, u64 num_walls);
function void r_map(Cam_2D map_cam, b32 show_player, Entity player, Border *walls, u64 num_walls);

#endif //RENDERER_H
