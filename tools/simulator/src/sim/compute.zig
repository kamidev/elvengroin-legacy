const std = @import("std");
const types = @import("types.zig");
const graph = @import("graph.zig");

pub var compute_fn: graph.fn_compute = undefined;

pub fn compute_f32_1(compute_id: graph.ComputeId, image_in_1: ?*types.ImageF32, image_out_1: *types.ImageF32, data: anytype) void {
    const width = if (image_in_1 != null) image_in_1.?.size.width else image_out_1.size.width;
    const height = if (image_in_1 != null) image_in_1.?.size.height else image_out_1.size.height;
    var compute_info = graph.ComputeInfo{
        .compute_id = compute_id,
        .buffer_width_in = @intCast(width),
        .buffer_height_in = @intCast(height),
        .buffer_width_out = @intCast(image_out_1.size.width),
        .buffer_height_out = @intCast(image_out_1.size.height),
        .in = if (image_in_1 != null) image_in_1.?.pixels.ptr else null,
        .out = image_out_1.pixels.ptr,
        .data_size = @sizeOf(@TypeOf(data)),
        .data = std.mem.asBytes(&data),
    };
    compute_fn(&compute_info);
}

pub fn compute_reduce_f32_1(compute_id: graph.ComputeId, operator_id: graph.ComputeOperatorId, image_in_1: *types.ImageF32, image_out_1: *types.ImageF32) void {
    var compute_info_gradient = graph.ComputeInfo{
        .compute_id = compute_id,
        .compute_operator_id = operator_id,
        .buffer_width_in = @intCast(image_in_1.size.width),
        .buffer_height_in = @intCast(image_in_1.size.height),
        .buffer_width_out = @intCast(image_out_1.size.width),
        .buffer_height_out = @intCast(image_out_1.size.height),
        .in = image_in_1.pixels.ptr,
        .out = image_out_1.pixels.ptr,
        .data_size = 0,
        .data = null,
    };
    compute_fn(&compute_info_gradient);
}

pub const GradientData = extern struct {
    g_buffer_width: u32,
    g_buffer_height: u32,
    g_height_ratio: f32,
    _padding: f32 = 0,
};

pub fn gradient(heightmap_in: *types.ImageF32, gradient_out: *types.ImageF32, height_ratio: f32) void {
    const gradient_data = GradientData{
        .g_buffer_width = @intCast(heightmap_in.size.width),
        .g_buffer_height = @intCast(heightmap_in.size.height),
        .g_height_ratio = height_ratio,
    };

    compute_f32_1(.gradient, heightmap_in, gradient_out, gradient_data);
}

pub fn min(image_in: *types.ImageF32, scratch: *types.ImageF32) void {
    compute_reduce_f32_1(.reduce, .min, image_in, scratch);
    image_in.height_min = scratch.pixels[0];
}

pub fn max(image_in: *types.ImageF32, scratch: *types.ImageF32) void {
    compute_reduce_f32_1(.reduce, .max, image_in, scratch);
    image_in.height_max = scratch.pixels[0];
}

pub fn fbm(image_out: *types.ImageF32, settings: anytype) void {
    compute_f32_1(.fbm, null, image_out, settings);
}

pub fn upsample_blur(image_in: *types.ImageF32, image_out: *types.ImageF32) void {
    const settings: extern struct {
        buffer_width: u32,
        buffer_height: u32,
        padding: [2]f32 = undefined,
    } = .{
        .buffer_width = @intCast(image_in.size.width),
        .buffer_height = @intCast(image_in.size.height),
    };
    compute_f32_1(.upsample_blur, image_in, image_out, settings);
}