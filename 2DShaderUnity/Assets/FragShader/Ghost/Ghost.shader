Shader "Custom/Frag/Ghost"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _GhostColorBoost ("Ghost Color Boost", Range(0, 5)) = 1
        _GhostTransparency ("Ghost Transparency", Range(0, 1)) = 0
        _GhostBlend ("Ghost Blend", Range(0, 1)) = 1
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
            half _GhostColorBoost, _GhostTransparency, _GhostBlend;

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
                

                half luminance = 0.3 * col.r + 0.59 * col.g + 0.11 * col.b;
                half4 ghostResult;
                ghostResult.a = saturate(luminance - _GhostTransparency) * col.a;
                ghostResult.rgb = col.rgb * (luminance + _GhostColorBoost);
                col = lerp(col, ghostResult, _GhostBlend);
                return col;
            }

            ENDCG
        }
    }
}