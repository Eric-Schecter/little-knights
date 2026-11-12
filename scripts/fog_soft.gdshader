shader_type canvas_item;
render_mode unshaded;
uniform sampler2D mask_texture : filter_nearest, repeat_disable;
// Cubic B-spline reconstruction has continuous slope across cell boundaries.
// Positive normalized weights avoid halos and opacity overshoot.
vec4 cubic_weights(float t) {
 float s=1.0-t;
 return vec4(s*s*s,3.0*t*t*t-6.0*t*t+4.0,-3.0*t*t*t+3.0*t*t+3.0*t+1.0,t*t*t)/6.0;
}
float smooth_mask(vec2 uv) {
 vec2 size=vec2(textureSize(mask_texture,0));
 vec2 pixel=uv*size-0.5;
 vec2 base=floor(pixel);
 vec4 wx=cubic_weights(fract(pixel.x));
 vec4 wy=cubic_weights(fract(pixel.y));
 float alpha=0.0;
 for(int y=0;y<4;y++) {
  for(int x=0;x<4;x++) {
   vec2 p=clamp(base+vec2(float(x-1),float(y-1)),vec2(0.0),size-1.0);
   alpha+=texture(mask_texture,(p+0.5)/size).a*wx[x]*wy[y];
  }
 }
 return alpha;
}
void fragment() {
 COLOR=vec4(0.07,0.085,0.10,smooth_mask(UV));
}
