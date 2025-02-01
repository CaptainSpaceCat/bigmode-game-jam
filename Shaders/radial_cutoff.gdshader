shader_type canvas_item;

// Define TWO_PI for convenience
const float TWO_PI = 6.28318530718;

uniform float progress: hint_range(0.0, 1.0) = 0; // 0 = nothing visible, 1 = full circle
uniform vec2 center = vec2(0.5, 0.5); // center of the circle in UV coordinates
uniform float start_angle = 4.71239; // starting angle in radians (0 is to the right, positive clockwise)
                                     // for now set it to 2/3 pi, in a float because fuck it
uniform bool clockwise = false; // if true, progress goes in the clockwise direction



void fragment() {
    // Calculate vector from the center
    vec2 delta = UV - center;
    
    // Get the angle in radians, in the range [-PI, PI]
    float angle = atan(delta.y, delta.x);
    
    // Normalize angle to [0, TWO_PI)
    if (angle < 0.0) {
        angle += TWO_PI;
    }
    
    // Adjust so that progress starts at start_angle
    float relative_angle = angle - start_angle;
    if (relative_angle < 0.0) {
        relative_angle += TWO_PI;
    }
    
    // Calculate threshold angle based on progress
    float threshold = progress * TWO_PI;
    
    // If clockwise is true, invert the direction of progress
    if (clockwise) {
        // Instead of showing from start_angle up to start_angle + threshold,
        // we show the opposite sector.
        relative_angle = TWO_PI - relative_angle;
    }
    
    // Optionally, you can add a smooth edge using smoothstep. Here we define an edge width.
    float edge_width = 0.02 * TWO_PI;  // adjust for antialiasing
    float mask = smoothstep(threshold, threshold - edge_width, relative_angle);
    
    // If the pixel is not in the visible region, discard it.
    if (mask < 0.5) {
        discard;
    }
    
    // Otherwise, sample the texture normally.
    COLOR = texture(TEXTURE, UV);
}
