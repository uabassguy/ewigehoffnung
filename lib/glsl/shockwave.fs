uniform sampler2D tex;

uniform float x, y, min, max, ratio, refraction;

void main(void)
{
    vec2 source_coords = gl_TexCoord[0].xy;
    vec3 color = texture2D(tex, source_coords).rgb;
    
    vec2 rel = source_coords - vec2(x,1.0-y);
    rel.x *= ratio;

    float dist = sqrt(rel.x*rel.x + rel.y*rel.y);
    float inner = (dist - min)/(max - min);

    if(dist >= min && dist <= max)
    {
        float depth = 0.5 + 0.5*cos((inner + 0.5) * 2.0 * 3.14159);
        source_coords -= depth * rel/dist * refraction;
        color = texture2D(tex, source_coords).rgb;
    }
    
    gl_FragColor.rgb = color;
}
