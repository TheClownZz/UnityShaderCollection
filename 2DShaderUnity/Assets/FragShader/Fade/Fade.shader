Shader "Custom/Frag/Fade"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _FadeTex ("Fade Texture", 2D) = "white" { }
        _FadeAmount ("Fade Amount", Range(-0.1, 1)) = -0.1
        _FadeBurnWidth ("Fade Burn Width", Range(0, 1)) = 0.025
        _FadeBurnTransition ("Burn Transition", Range(0.01, 0.5)) = 0.075
        _FadeBurnColor ("Fade Burn Color", Color) = (1, 1, 0, 1)
        _FadeBurnTex ("Fade Burn Texture", 2D) = "white" { }
        _FadeBurnGlow ("Fade Burn Glow", Range(1, 250)) = 2
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

            sampler2D _FadeTex, _FadeBurnTex;
            half4 _FadeBurnColor, _FadeTex_ST, _FadeBurnTex_ST;
            half _FadeAmount, _FadeBurnWidth, _FadeBurnTransition, _FadeBurnGlow;
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

                half2 tiledUvFade1 = TRANSFORM_TEX(i.uv, _FadeTex);
                half2 tiledUvFade2 = TRANSFORM_TEX(i.uv, _FadeBurnTex);
                half fadeTemp = tex2D(_FadeTex, tiledUvFade1).r;
                half fade = smoothstep(_FadeAmount + 0.01, _FadeAmount + _FadeBurnTransition, fadeTemp);
                col.a *= fade;

                half fadeBurn = saturate(smoothstep(_FadeAmount - _FadeBurnWidth, _FadeAmount - _FadeBurnWidth + 0.1, fadeTemp) * _FadeAmount);
                _FadeBurnColor.rgb *= _FadeBurnGlow;
                col += fadeBurn * tex2D(_FadeBurnTex, tiledUvFade2) * _FadeBurnColor * col.a * (1 - col.a);

                return col;
            }

            ENDCG
        }
    }
}