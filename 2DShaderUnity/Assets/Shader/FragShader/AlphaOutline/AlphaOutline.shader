Shader "Custom/Frag/AlphaOutline"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _AlphaOutlineColor ("Color", Color) = (1, 1, 1, 1)
        _AlphaOutlineGlow ("Outline Glow", Range(1, 100)) = 5
        _AlphaOutlinePower ("Power", Range(0, 5)) = 1
        _AlphaOutlineMinAlpha ("Min Alpha", Range(0, 1)) = 0
        _AlphaOutlineBlend ("Blend", Range(0, 1)) = 1
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


            half _AlphaOutlineGlow, _AlphaOutlinePower, _AlphaOutlineMinAlpha, _AlphaOutlineBlend;
            half4 _AlphaOutlineColor;
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

                half alphaOutlineRes = pow(1 - col.a, max(_AlphaOutlinePower, 0.0001)) * step(_AlphaOutlineMinAlpha, col.a) * _AlphaOutlineBlend;
                col.rgb = lerp(col.rgb, _AlphaOutlineColor.rgb * _AlphaOutlineGlow, alphaOutlineRes);
                col.a = lerp(col.a, 1, alphaOutlineRes > 1);
                return col;
            }

            ENDCG
        }
    }
}