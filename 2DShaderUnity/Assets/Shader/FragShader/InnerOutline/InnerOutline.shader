Shader "Custom/Frag/InnerOutline"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _InnerOutlineColor ("Inner Outline Color", Color) = (1, 0, 0, 1) 
        _InnerOutlineThickness ("Outline Thickness", Range(0, 3)) = 1 
        _InnerOutlineAlpha ("Inner Outline Alpha", Range(0, 1)) = 1 
        _InnerOutlineGlow ("Inner Outline Glow", Range(1, 250)) = 4 

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
            float4 _MainTex_ST, _MainTex_TexelSize;

            half _InnerOutlineThickness, _InnerOutlineAlpha, _InnerOutlineGlow;
            half4 _InnerOutlineColor;
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

            half3 GetPixel(in int offsetX, in int offsetY, half2 uv, sampler2D tex)
            {
                return tex2D(tex, (uv + half2(offsetX * _MainTex_TexelSize.x, offsetY * _MainTex_TexelSize.y))).rgb;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                half3 innerT = abs(GetPixel(0, _InnerOutlineThickness, i.uv, _MainTex) - GetPixel(0, -_InnerOutlineThickness, i.uv, _MainTex));
                innerT += abs(GetPixel(_InnerOutlineThickness, 0, i.uv, _MainTex) - GetPixel(-_InnerOutlineThickness, 0, i.uv, _MainTex));
                innerT = (innerT / 2.0) * col.a * _InnerOutlineAlpha;
                col.rgb += length(innerT) * _InnerOutlineColor.rgb * _InnerOutlineGlow;
                return col;
            }

            ENDCG
        }
    }
}