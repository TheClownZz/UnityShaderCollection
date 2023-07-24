Shader "Custom/Frag/Glow"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _GlowColor ("Glow Color", Color) = (1, 1, 1, 1)
        _Glow ("Glow Color Intensity", Range(0, 100)) = 10
        _GlowGlobal ("Global Glow Intensity", Range(1, 100)) = 1
        [NoScaleOffset] _GlowTex ("Glow Texture", 2D) = "white" { }
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
            #pragma shader_feature GLOWTEX

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GlowTex;
            half4 _GlowColor;
            half _Glow, _GlowGlobal;

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

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                half4 emission;
                #if GLOWTEX
                    emission = tex2D(_GlowTex, i.uv);
                #else
                    emission = col;
                #endif
                //         emission = tex2D(_GlowTex, i.uv);

                col.rgb *= _GlowGlobal;
                emission.rgb *= emission.a * col.a * _Glow * _GlowColor;
                col.rgb += emission.rgb;

                col *= i.color;
                return col;
            }

            ENDCG
        }
    }

    CustomEditor "ShaderFeatureCustom"
}