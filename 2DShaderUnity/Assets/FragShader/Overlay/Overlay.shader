Shader "Custom/Frag/Overlay"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _OverlayTex ("Overlay Texture", 2D) = "white" { }//160
        _OverlayColor ("Overlay Color", Color) = (1, 1, 1, 1) //161
        _OverlayGlow ("Overlay Glow", Range(0, 25)) = 1 // 162
        _OverlayBlend ("Overlay Blend", Range(0, 1)) = 1 // 163

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
            #pragma shader_feature OVERLAYMULT_ON

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _OverlayTex;
            half4 _OverlayTex_ST, _OverlayColor;
            half _OverlayGlow, _OverlayBlend;
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
                half4 overlayCol = tex2D(_OverlayTex, TRANSFORM_TEX(i.uv, _OverlayTex));
                overlayCol.rgb *= _OverlayColor.rgb * _OverlayGlow;
                #if !OVERLAYMULT_ON
                    overlayCol.rgb *= overlayCol.a * _OverlayColor.rgb * _OverlayColor.a * _OverlayBlend;
                    col.rgb += overlayCol;
                #else
                    overlayCol.a *= _OverlayColor.a;
                    col = lerp(col, col * overlayCol, _OverlayBlend);
                #endif
                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}