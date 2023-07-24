Shader "Custom/Uv/Pinch"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _PinchUvAmount ("Pinch Amount", Range(0, 0.5)) = 0.35
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

            half _PinchUvAmount;

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
                half2 center = half2(0.5, 0.5);
                half2 centerTiled = half2(center.x * _MainTex_ST.x, center.y * _MainTex_ST.y);
                half2 dP = i.uv - centerTiled;
                half pinchInt = (3.141592 / length(centerTiled)) * (-_PinchUvAmount + 0.001);
                i.uv = centerTiled + normalize(dP) * atan(length(dP) * - pinchInt * 10.0) * 0.5 / atan(-pinchInt * 5);

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                return col;
            }

            ENDCG
        }
    }
}