Shader "Custom/Frag/Outline"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" { }

        _OutlineColor ("Outline Base Color", Color) = (1, 1, 1, 1)
        _OutlineAlpha ("Outline Base Alpha", Range(0, 1)) = 1
        _OutlineGlow ("Outline Base Glow", Range(1, 100)) = 1.5
        _OutlineWidth ("Outline Base Width", Range(0, 20)) = 0.5

        [Space]
        _OutlineTex ("Outline Texture", 2D) = "white" { }
        _OutlineTexXSpeed ("Texture scroll speed X", Range(-50, 50)) = 10
        _OutlineTexYSpeed ("Texture scroll speed Y", Range(-50, 50)) = 0

        [Space]
        _OutlineDistortTex ("Outline Distortion Texture", 2D) = "white" { }
        _OutlineDistortAmount ("Outline Distortion Amount", Range(0, 2)) = 0.5
        _OutlineDistortTexXSpeed ("Distortion scroll speed X", Range(-50, 50)) = 5
        _OutlineDistortTexYSpeed ("Distortion scroll speed Y", Range(-50, 50)) = 5
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
            #pragma shader_feature ONLYOUTLINE

            #pragma shader_feature OUTTEX
            #pragma shader_feature OUTDIST
            #pragma shader_feature OUTBASE8DIR

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST, _MainTex_TexelSize;

            half4 _OutlineColor;
            half _OutlineAlpha, _OutlineGlow, _OutlineWidth;

            #if OUTTEX
                sampler2D _OutlineTex;
                half4 _OutlineTex_ST;
                half _OutlineTexXSpeed, _OutlineTexYSpeed;
            #endif

            #if OUTDIST
                sampler2D _OutlineDistortTex;
                half4 _OutlineDistortTex_ST;
                half _OutlineDistortTexXSpeed, _OutlineDistortTexYSpeed, _OutlineDistortAmount;
            #endif

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

                #if OUTTEX
                    half2 uvOutTex : TEXCOORD1;
                #endif

                #if OUTDIST
                    half2 uvOutDistTex : TEXCOORD2;
                #endif
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;

                #if OUTTEX
                    o.uvOutTex = TRANSFORM_TEX(v.uv, _OutlineTex);
                #endif
                #if OUTDIST
                    o.uvOutDistTex = TRANSFORM_TEX(v.uv, _OutlineDistortTex);
                #endif
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.color;
                half2 destUv = half2(_OutlineWidth * _MainTex_TexelSize.x, _OutlineWidth * _MainTex_TexelSize.y);

                #if OUTDIST
                    i.uvOutDistTex.x += frac(_Time  * _OutlineDistortTexXSpeed);
                    i.uvOutDistTex.y += frac(_Time  * _OutlineDistortTexYSpeed);
                    
                    half outDistortAmnt = (tex2D(_OutlineDistortTex, i.uvOutDistTex).r - 0.5) * 0.2 * _OutlineDistortAmount;
                    destUv.x += outDistortAmnt;
                    destUv.y += outDistortAmnt;
                #endif

                half spriteLeft = tex2D(_MainTex, i.uv + half2(destUv.x, 0)).a;
                half spriteRight = tex2D(_MainTex, i.uv - half2(destUv.x, 0)).a;
                half spriteBottom = tex2D(_MainTex, i.uv + half2(0, destUv.y)).a;
                half spriteTop = tex2D(_MainTex, i.uv - half2(0, destUv.y)).a;
                half result = spriteLeft + spriteRight + spriteBottom + spriteTop;

                #if OUTBASE8DIR
                    half spriteTopLeft = tex2D(_MainTex, i.uv + half2(destUv.x, destUv.y)).a;
                    half spriteTopRight = tex2D(_MainTex, i.uv + half2(-destUv.x, destUv.y)).a;
                    half spriteBotLeft = tex2D(_MainTex, i.uv + half2(destUv.x, -destUv.y)).a;
                    half spriteBotRight = tex2D(_MainTex, i.uv + half2(-destUv.x, -destUv.y)).a;
                    result = result + spriteTopLeft + spriteTopRight + spriteBotLeft + spriteBotRight;
                #endif
                
                result = step(0.05, saturate(result));

                #if OUTTEX
                    i.uvOutTex.x += frac(_Time  * _OutlineTexXSpeed);
                    i.uvOutTex.y += frac(_Time  * _OutlineTexYSpeed);

                    half4 tempOutColor = tex2D(_OutlineTex, i.uvOutTex);
                    tempOutColor *= _OutlineColor;
                    _OutlineColor = tempOutColor;
                #endif

                result *= (1 - col.a) * _OutlineAlpha;

                half4 outline = _OutlineColor * i.color.a;
                outline.rgb *= _OutlineGlow;
                outline.a = result;
                #if ONLYOUTLINE
                    col = outline;
                #else
                    col = lerp(col, outline, result);
                #endif

                return col;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderFeatureCustom"
}

