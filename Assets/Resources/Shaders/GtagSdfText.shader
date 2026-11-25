// Minimal signed-distance-field text shader for the menu (built-in pipeline, works on Quest / Vulkan, single-pass instanced stereo).
// It replaces "TextMeshPro/Distance Field", which drew as solid magenta blocks in the Android build.
// It lives in Resources/ so Unity always puts it into the build, and it declares the properties TextMeshPro looks for
// (_GradientScale ...) so TextMeshPro still sizes the glyph quads correctly.
Shader "GtagTest/SdfText"
{
    Properties
    {
        _MainTex ("Font Atlas", 2D) = "white" {}
        _FaceColor ("Face Color", Color) = (1,1,1,1)
        _FaceDilate ("Face Dilate", Range(-1,1)) = 0
        _OutlineWidth ("Outline Thickness", Range(0,1)) = 0
        _OutlineSoftness ("Outline Softness", Range(0,1)) = 0
        _WeightNormal ("Weight Normal", Float) = 0
        _WeightBold ("Weight Bold", Float) = 0.5
        _GradientScale ("Gradient Scale", Float) = 6
        _ScaleRatioA ("Scale RatioA", Float) = 1
        _ScaleRatioB ("Scale RatioB", Float) = 1
        _ScaleRatioC ("Scale RatioC", Float) = 1
        _ShaderFlags ("Flags", Float) = 0
        _Sharpness ("Sharpness", Range(-1,1)) = 0
        _TextureWidth ("Texture Width", Float) = 512
        _TextureHeight ("Texture Height", Float) = 512
        _PerspectiveFilter ("Perspective Correction", Range(0,1)) = 0.875
        _VertexOffsetX ("Vertex OffsetX", Float) = 0
        _VertexOffsetY ("Vertex OffsetY", Float) = 0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _FaceColor;

            struct appdata
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float d = tex2D(_MainTex, i.uv).a;          // 0.5 = the glyph's edge
                float w = max(fwidth(d), 0.0001);            // one pixel of anti-aliasing
                float a = smoothstep(0.5 - w, 0.5 + w, d);
                fixed4 c = i.color * _FaceColor;
                c.a *= a;
                clip(c.a - 0.01);
                return c;
            }
            ENDCG
        }
    }
    Fallback Off
}
