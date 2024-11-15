const std = @import("std");

const BlendError = error{
    InvalidAlpha,
};

const ConversionError = error{
    InvalidHex,
};

const RGBColor = struct {
    R: u8,
    G: u8,
    B: u8,
};

/// Convert an RGB color into its equivalant hex representation
fn RGBToHex(rgb: RGBColor) [7]u8 {
    var hex: [7]u8 = undefined;
    _ = std.fmt.bufPrint(&hex, "#{x:0>2}{x:0>2}{x:0>2}", .{ rgb.R, rgb.G, rgb.B }) catch unreachable;
    return hex;
}

/// Convert a hex color into its equivalent RGB representation
///
/// The hex input must begin with '#', e.g. '#88d8c0'
fn hexToRGB(hex: [7]u8) !RGBColor {
    const InvalidHex = ConversionError.InvalidHex;
    if (hex[0] != '#') {
        return InvalidHex;
    }
    // Convert hex values to decimal
    const R = std.fmt.parseInt(u8, hex[1..3], 16) catch return InvalidHex;
    const G = std.fmt.parseInt(u8, hex[3..5], 16) catch return InvalidHex;
    const B = std.fmt.parseInt(u8, hex[5..7], 16) catch return InvalidHex;
    return RGBColor{ .R = R, .B = B, .G = G };
}

/// Blend color 1 into color 2 with an alpha value (mixing coefficient)
///
/// If alpha = 0.0, returns color 2
/// If alpha = 1.0, returns color 1
/// If alpha = 0.6, returns color 1 mixed 60% into color 2
fn blendColors(col1: RGBColor, col2: RGBColor, alpha: f16) !RGBColor {
    if (alpha < 0 or alpha > 1) {
        return BlendError.InvalidAlpha;
    }
    const r1: f16 = @floatFromInt(col1.R);
    const r2: f16 = @floatFromInt(col2.R);
    const g1: f16 = @floatFromInt(col1.G);
    const g2: f16 = @floatFromInt(col2.G);
    const b1: f16 = @floatFromInt(col1.B);
    const b2: f16 = @floatFromInt(col2.B);

    return RGBColor{
        .R = @intFromFloat(r1 * alpha + r2 * (1 - alpha)),
        .G = @intFromFloat(g1 * alpha + g2 * (1 - alpha)),
        .B = @intFromFloat(b1 * alpha + b2 * (1 - alpha)),
    };
}

/// Print text with a foreground or background color
fn colored(text: []const u8, color: RGBColor, is_background: bool) void {
    const ground: u8 = if (is_background) 48 else 38;
    std.debug.print("\x1b[{d};2;{d};{d};{d}m{s}\x1b[0m", .{
        ground,
        color.R,
        color.G,
        color.B,
        text,
    });
}

/// Print a color together with its hex value
fn printColor(color: RGBColor) void {
    colored(" ", color, true);
    std.debug.print(" {s}\n", .{RGBToHex(color)});
}

pub fn main() !void {
    const col1 = "#88d8c0";
    const col2 = "#f5f5dc";
    const rgb1: RGBColor = try hexToRGB(col1.*);
    const rgb2: RGBColor = try hexToRGB(col2.*);
    const blendedRGB = try blendColors(rgb1, rgb2, 0.5);

    printColor(rgb1);
    printColor(rgb2);
    printColor(blendedRGB);
}
