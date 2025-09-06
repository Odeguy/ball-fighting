shader_type canvas_item;

group_uniforms Basics;
uniform float radius: hint_range(0.0, 2.0, 0.001) = 0.1;
uniform float blur: hint_range(-1.0, 1.0, 0.0001) = 0.0001;
uniform vec2 position;
uniform mediump float ratio = 1.7066;
uniform vec2 tiling = vec2(0.0, 0.0);

group_uniforms Animations.Ellipse;
uniform float ellipseRadius: hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform mediump float ellipseSpeed = 1.0;

group_uniforms Animations.Size;
uniform mediump float shrink;
uniform mediump float enlarge;

group_uniforms Animations.Colors;
uniform mediump float bounceColor;
uniform mediump float hitColor;
uniform float colorRadius: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform int bounceFrom: hint_enum("None", "Red", "Green", "Blue", "Transparency") = 0;
uniform int noBounceFrom: hint_enum("None", "Red", "Green", "Blue", "Transparency") = 0;
uniform int hitFrom: hint_enum("None", "Red", "Green", "Blue", "Transparency") = 0;
uniform int radialColor: hint_enum("None", "Red", "Green", "Blue") = 0;

group_uniforms Animations.StripedColors;
uniform float frequency = 5.0;
uniform float sineSpeed = 5.0;
uniform bool intermittentColor = false;
uniform vec4 color1: source_color = vec4(1.0);
uniform vec4 color2: source_color;
uniform float innerColor: hint_range(0.1, 10.0) = 1.0;

group_uniforms Animations.Movement;
uniform mediump float speedX;
uniform mediump float amplitudeX = 0.1;
uniform mediump float speedY;
uniform mediump float amplitudeY = 0.1;
uniform mediump float wululu;
uniform mediump float delay;
uniform bool dropEffect;

group_uniforms Animations.Blur;
uniform mediump float breathe;
uniform mediump float heartbeat;
uniform bool limit;

group_uniforms Star;
uniform bool useStar = false;
uniform int starPoints : hint_range(3, 20) = 5;
uniform float starRotation = 0.95;
uniform float rotationSpeed = 0.0;
uniform float sharpness = 1.0;

//////////////////////////////////////////////////
// === FUNCTIONS ===============================
//////////////////////////////////////////////////

float circle(vec2 uv, float radiusVar, float blurEffect) {
    float distance = length(uv);
    float circumference = smoothstep(
        radiusVar,
        radiusVar + clamp(blurEffect, limit ? 0.0 : -1.0, 1.0),
        distance
    );
    return 1.0 - circumference;
}

float polarStar(in vec2 p) {
    float pi_n = PI / float(starPoints);
    float m2 = mod(atan(p.y, p.x) / pi_n + 1.0, 2.0);
    float adjust = -sharpness;
    return length(p) * cos((pi_n * adjust) * (m2 - 4.0 * step(1.0, m2) + 1.0)) - 1.0;
}

//////////////////////////////////////////////////
// === FRAGMENT ================================
//////////////////////////////////////////////////

void fragment() {
    vec2 uv = (UV - 0.5) * (2.0 + tiling);
    uv.x *= ratio;
    vec2 p = position / 100.0;

    float ss = shrink == 0.0 ? 1.0 : sin(TIME * shrink);
    float ts = enlarge == 0.0 ? 1.0 : tan(TIME * enlarge);
    float sc = sin(TIME * bounceColor);
    float tc = tan(TIME * hitColor);
    float sineB = breathe == 0.0 ? 0.0 : sin(TIME * breathe);
    float tanB = heartbeat == 0.0 ? 1.0 : sin(TIME * heartbeat);
    float sp2 = wululu == 0.0 ? 1.0 : sin(TIME * wululu);

    float animatedRadius = radius * ss * ts;
    float animatedBlur = (blur + sineB) * tanB;

    float angle = TIME * ellipseSpeed - delay;
    vec2 offset = vec2(cos(angle), sin(angle)) * ellipseRadius;
    vec2 offsetColor = vec2(cos(angle), sin(angle)) * colorRadius;

    vec2 animatedPosition = vec2(
        sin(speedX * (TIME - delay)) * amplitudeX,
        sin(speedY * (TIME - delay)) * amplitudeY
    );
    if (dropEffect) {
        animatedPosition = vec2(
            tan(speedX * (TIME - delay)) * amplitudeX,
            tan(speedY * (TIME - delay)) * amplitudeY
        );
    }

    vec2 base_uv = uv + offset + p + animatedPosition * sp2;

    float totalRotation = starRotation + TIME * rotationSpeed;
    mat2 rotationMatrix = mat2(vec2(cos(totalRotation), -sin(totalRotation)), vec2(sin(totalRotation), cos(totalRotation)));

    float c03;
    if (useStar) {
        vec2 rotated_uv = rotationMatrix * base_uv / animatedRadius;
        c03 = 1.0 - smoothstep(
            1.0,
            1.0 + clamp(animatedBlur, limit ? 0.0 : -1.0, 1.0),
            abs(polarStar(rotated_uv))
        );
    } else {
        c03 = circle(base_uv, animatedRadius, animatedBlur);
    }

    vec4 Sine[5] = {
        vec4(0.0),
        vec4(float(sc), 0.0, 0.0, 0.0),
        vec4(0.0, float(sc), 0.0, 0.0),
        vec4(0.0, 0.0, float(sc), 0.0),
        vec4(0.0, 0.0, 0.0, float(sc))
    };

    vec4 Cosine[5] = {
        vec4(0.0),
        vec4(float(-sc), 0.0, 0.0, 0.0),
        vec4(0.0, float(-sc), 0.0, 0.0),
        vec4(0.0, 0.0, float(-sc), 0.0),
        vec4(0.0, 0.0, 0.0, float(-sc))
    };

    vec4 Tangent[5] = {
        vec4(0.0),
        vec4(float(tc), 0.0, 0.0, 0.0),
        vec4(0.0, float(tc), 0.0, 0.0),
        vec4(0.0, 0.0, float(tc), 0.0),
        vec4(0.0, 0.0, 0.0, float(tc))
    };

    vec4 Radial[4] = {
        vec4(0.0),
        vec4(offsetColor, 0.0, 0.0),
        vec4(0.0, offsetColor, 0.0),
        vec4(0.0, 0.0, offsetColor)
    };

    vec3 CrazyColors = Sine[bounceFrom].rgb + Cosine[noBounceFrom].rgb + Tangent[hitFrom].rgb + Radial[radialColor].rgb;
    float Transparencies = Sine[bounceFrom].a + Cosine[noBounceFrom].a + Tangent[hitFrom].a;

    // === INNER PATTERN WITH ALPHA FROM COLOR1 and COLOR2 ===
    vec2 uv_pattern = rotationMatrix * base_uv / animatedRadius;
    float pattern_value = useStar ? polarStar(uv_pattern) : length(uv_pattern);
    float d = sin(pattern_value * frequency + TIME * sineSpeed) / 10.0;
    d = smoothstep(0.0, 0.0, d);

    float clip = useStar
        ? polarStar(uv_pattern * innerColor)
        : length(uv_pattern * innerColor) - 1.0;

    clip = smoothstep(1.0, 1.0, clip);
    d -= clip;

    // Here color1.a and color2.a are used
    vec4 white_col = vec4(color1.rgb * d, color1.a * d);
    vec4 black_col = vec4(color2.rgb * (1.0 - (d + clip)), color2.a * (1.0 - (d + clip)));
    vec4 decorative = intermittentColor ? (white_col + black_col) : vec4(0.0);

    // === FINAL COLOR ===
    vec4 finalColor = vec4(COLOR.rgb + CrazyColors, (COLOR.a + Transparencies) * c03);
    if (intermittentColor) {
        finalColor.rgb = mix(finalColor.rgb, decorative.rgb, c03);
        finalColor.a = mix(finalColor.a, decorative.a, c03);
    } else {
        finalColor.a *= c03;
    }

    COLOR = finalColor;
}
