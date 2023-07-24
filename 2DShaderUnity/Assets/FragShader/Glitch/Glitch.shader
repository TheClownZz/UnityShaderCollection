Shader "Custom/Frag/Glitch"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _GlitchSize ("Glitch Size", Range(0.25, 5)) = 1
        _GlitchAmount ("Glitch Amount", Range(0, 20)) = 3
        [HideInInspector] _RandomSeed ("_MaxYUV", Range(0, 10000)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite off
        Cull off

        Pass
        {

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _GlitchAmount, _GlitchSize;
            float _RandomSeed;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            half rand2(half2 seed, half offset)
            {
                return (frac(sin(dot(seed * floor(50 + (_Time % 1.0) * 12.), half2(127.1, 311.7))) * 43758.5453123) + offset) % 1.0;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                half2 uvGlitch = i.uv;
                half lineNoise = pow(rand2(floor(uvGlitch * half2(24., 19.) * _GlitchSize) * 4.0, _RandomSeed), 3.0) * _GlitchAmount
                * pow(rand2(floor(uvGlitch * half2(38., 14.) * _GlitchSize) * 4.0, _RandomSeed), 3.0);

                fixed4 col = tex2D(_MainTex, i.uv + half2(lineNoise * 0.02 * rand2(half2(2.0, 1), _RandomSeed), 0)) * i.color;
                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}