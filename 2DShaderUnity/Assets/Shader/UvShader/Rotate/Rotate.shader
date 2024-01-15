Shader "Custom/Uv/RotateM"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        
        _RotateUvAmount ("Rotate Angle(radians)", Range(0, 6.2831)) = 0
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

            half _RotateUvAmount;

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

                half2 center = half2(0.5, 0.5);
                half2 uvC = v.uv;
                half cosAngle = cos(_RotateUvAmount);
                half sinAngle = sin(_RotateUvAmount);
                half2x2 rot = half2x2(cosAngle, -sinAngle, sinAngle, cosAngle);
                uvC -= center;
                o.uv = mul(rot, uvC);
                o.uv += center;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {

                
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                return col;
            }

            ENDCG
        }
    }
}