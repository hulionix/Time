#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926535897932384626433832795

uniform vec2 u_resolution;
uniform float u_time;


// Simplex 2D noise - source: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
           -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
// ------------------------------------------------------------

vec4 colorE = vec4(0.024,0.024,0.025,0.100);
vec4 colorD = vec4(0.000,1.000,0.867,1.000);
vec4 colorC = vec4(0.353,0.165,0.720,1.000);
vec4 colorB = vec4(0.965,0.037,0.299,1.000);
vec4 colorA = vec4(0.605,0.005,0.127,1.000);

float aspect = u_resolution.y / u_resolution.x;

vec4 bgColor(float length) {
    return mix(colorE, mix(colorA,
               mix(colorB,
                   mix(colorC,
                       mix(colorD, colorE, smoothstep(0.6, 4.8, length)),
                       smoothstep(0.6, 1.9, length)),
                 smoothstep(0.2, 0.6, length)),
             smoothstep(0.0, 0.3, length)), smoothstep(0.0, 0.9, length));
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
   	vec2 uv = st * vec2(1.0, aspect);
    //uv.y = mod(0.5, uv.y);
    float n = fract(snoise(uv - u_time /20.0));
    float highn = fract(snoise(50.0 * uv * vec2(u_time * uv.y * uv.x, u_time * n * uv.y)));
    float dist = distance(vec2(highn / 10.0, n * aspect), uv) / 0.3119;
    uv.x = uv.y * dist;

    gl_FragColor = bgColor(uv.y / (uv.x * uv.x));
}
