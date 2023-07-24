Shader "Custom/Frag/Shine"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _ShineColor ("Shine Color", Color) = (1, 1, 1, 1)
        _ShineLocation ("Shine Location", Range(0, 1)) = 0.5
        _ShineRotate ("Rotate Angle(radians)", Range(0, 6.2831)) = 0
        _ShineWidth ("Shine Width", Range(0.05, 1)) = 0.1
        _ShineGlow ("Shine Glow", Range(0, 100)) = 1
        [NoScaleOffset] _ShineMask ("Shine Mask", 2D) = "white" { }
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

            sampler2D _ShineMask;
            half4 _ShineColor;
            half _ShineLocation, _ShineRotate, _ShineWidth, _ShineGlow;


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
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                half2 uvShine = i.uv;
                half cosAngle = cos(_ShineRotate);
                half sinAngle = sin(_ShineRotate);
                half2x2 rot = half2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
                uvShine -= half2(0.5, 0.5);
                uvShine = mul(rot, uvShine);
                uvShine += half2(0.5, 0.5);
                half shineMask = tex2D(_ShineMask, i.uv).a;
                half currentDistanceProjection = (uvShine.x + uvShine.y) / 2;
                half whitePower = 1 - (abs(currentDistanceProjection - _ShineLocation) / _ShineWidth);
                col.rgb += col.a * whitePower * _ShineGlow
                * max(sign(currentDistanceProjection - (_ShineLocation - _ShineWidth)), 0.0)
                * max(sign((_ShineLocation + _ShineWidth) - currentDistanceProjection), 0.0)
                * _ShineColor * shineMask
                ;
                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}