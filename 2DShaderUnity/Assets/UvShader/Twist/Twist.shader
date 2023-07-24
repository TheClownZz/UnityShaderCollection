Shader "Custom/Uv/Twist"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }
        _TwistUvAmount ("Twist Amount", Range(0, 3.1416)) = 1 
        _TwistUvPosX ("Twist Pos X Axis", Range(0, 1)) = 0.5
        _TwistUvPosY ("Twist Pos Y Axis", Range(0, 1)) = 0.5 
        _TwistUvRadius ("Twist Radius", Range(0, 3)) = 0.75 

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

            half _TwistUvAmount, _TwistUvPosX, _TwistUvPosY, _TwistUvRadius;

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
                half2 tempUv = i.uv - half2(_TwistUvPosX * _MainTex_ST.x, _TwistUvPosY * _MainTex_ST.y);
                _TwistUvRadius *= (_MainTex_ST.x + _MainTex_ST.y) / 2;
                half percent = (_TwistUvRadius - length(tempUv)) / _TwistUvRadius;
                half theta = percent * percent * (2.0 * sin(_TwistUvAmount)) * 8.0;
                half s = sin(theta);
                half c = cos(theta);
                half beta = max(sign(_TwistUvRadius - length(tempUv)), 0.0);
                tempUv = half2(dot(tempUv, half2(c, -s)), dot(tempUv, half2(s, c))) * beta + tempUv * (1 - beta);
                tempUv += half2(_TwistUvPosX * _MainTex_ST.x, _TwistUvPosY * _MainTex_ST.y);
                i.uv = tempUv;

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;

                return col;
            }

            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}