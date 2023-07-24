Shader "Custom/Frag/HitEffect"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        

        _HitEffectColor ("Hit Effect Color", Color) = (1, 1, 1, 1)
        _HitEffectGlow ("Glow Intensity", Range(1, 100)) = 5
        _HitEffectBlend ("Hit Effect Blend", Range(0, 1)) = 1
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

            half4 _HitEffectColor;
            half _HitEffectGlow, _HitEffectBlend;

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
                col *= i.color;

                col.rgb = lerp(col.rgb, _HitEffectColor.rgb * _HitEffectGlow, _HitEffectBlend);
                return col;
            }

            ENDCG
        }
    }
}