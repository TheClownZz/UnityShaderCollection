Shader "Custom/Frag/Shadow"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _ShadowX ("Shadow X Axis", Range(-0.5, 0.5)) = 0.1
        _ShadowY ("Shadow Y Axis", Range(-0.5, 0.5)) = -0.05
        _ShadowAlpha ("Shadow Alpha", Range(0, 1)) = 0.5
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 1)
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
            half _ShadowX, _ShadowY, _ShadowAlpha;
            half4 _ShadowColor;

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
                
                half shadowA = tex2D(_MainTex, i.uv + half2(_ShadowX, _ShadowY)).a;
                half preMultShadowMask = 1 - (saturate(shadowA - col.a) * (1 - col.a));
                col.rgb *= 1 - ((shadowA - col.a) * (1 - col.a));
                col.rgb += (_ShadowColor * shadowA) * (1 - col.a);
                col.a = max(shadowA * _ShadowAlpha * i.color.a, col.a);

                return col;
            }

            ENDCG
        }
    }
}