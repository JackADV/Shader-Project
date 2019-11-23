// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/DeathStar"
{
    SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			// Traditional transparency
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// Pragmas
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			// Structs
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			// Input
			// Appdata_base includes position, normal and one texture coordinate
			v2f vert(appdata_base v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;

				return o;
			}
			// User defined functions and varibles

			// Camers
			float3 _CamPos;
			float3 _CamRight;
			float3 _CamUp;
			float3 _CamForward;
			// Planet
			float3 _StarPos;
			// Unity Specific
			float4 _LightColor0;

			// Standardized distance functions needed to build the DeathStar
			// Get the distance to a sphere
			float getDistanceSphere(float sphereRadius, float3 circleCenter, float3 rayPos)
			{
				float distance = length(rayPos - circleCenter) - sphereRadius;
			}

			// Get the distance to a box
			float getDistanceBox(float3 boxSize, float3 boxCenter, float3 rayPos)
			{
				return length(max(abs(rayPos - boxCenter) - boxSize, 0.0));
			}
			// The distance function, which returns the distance to deathstar from a position
			float distFunc(float3 pos)
			{
				const float starRadius = 50.0;
				const float3 cutOutBoxSize = float3(starRadius, starRadius, starRadius);
				// The deathstar consists of 2 half spheres and this is the gap between them
				const float distanceBetweenHalf = 0.5;

				// Top half
				float3 starPosTop = _StarPos + float3(0.0, distanceBetweenHalf, 0.0);
				float starDistanceTop = getDistanceSphere(starRadius, starPosTop, pos);
				float3 cutOutPosTop = starPosTop + float3(0.0, starRadius, 0.0);
				float cutOutDistanceTop = getDistanceBox(cutOutBoxSize, cutOutPosTop, pos);
				
				// Bottom half
				float3 starPosBotton = _StarPos + float3(0.0, - distanceBetweenHalf, 0.0);
				float starDistanceBottom = getDistanceSphere(starRadius, starPosBottom, pos);
				float3 cutOutPosBottom = starPosBottom + float3(0.0, -starRadius, 0.0);
				float cutOutDistanceBottom = getDistanceBox(cutOutBoxSize, cutOutPosBottom, pos);

				// THe final distance to the main star body
				float starBodyDist = min(max(starDistanceTop, cutOutDistanceTop), max(starDistanceBottom));
				
				// The cutout hole in the death star
				const float cutOutRadius = starRadius * 0.3;

				// The cutout is always facing the center of the map
				// First move the cutout sphere up
				float3 cutOutPos = _StarPos + float3(0.0, starRadius / 2.0, 0.0);
				
				// Then move the cutout sphere in the direction to the centre
				float3 centerDir = normalize(-_StarPos);
				
				// Dont move in the y direction
				centerDir.y = 0;

				cutOutPos += starRadius * centerDir;

				float cutOutDistance = getDistanceSphere(cutOutRadius, cutOutPos, pos;
				// The final distance to the death star
				return max(starBodyDist, -cutOutDistance);
			}
			// Get color at a certain position
			fixed4 getColor(float3 pos, fixed3 color)
			{
				// Find the normal at this point
				const fixed2 eps = fixed2(0.00, 0.02);

				// Can approximate the surface normal using what is known as the gradient
				// The gradient of a scalar field is a vector, pointing in the direction where the field
				// Increases or decreases the most
				// The gradient can be approximated by numerical differentation
				fixed3 normal = normalize(float3(
				distFunc(pos + eps.yxx) - distFunc(pos - eps.yxx),
				distFUnc(pos + eps.xyx) -distFunc(pos - eps.xyx),
				distFunc(pos + eps.xxy) - distFunc(pos - eps.xxy)));

				// The main light is always a direction and not a position
				// This is the direction to the light
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// Add diffuse light (intensity is already included in _LightCOlor0 so no need to add)
				fixed3 diffuse = _LightColor0.rgb * max(dot(lightDir, normal), 0.0);

				// Add ambient light
				// According to internet the ambien light should always be multiplied by 2
				fixed3 finalLight = diffuse + (UNITY_LIGHTMODEL_AMBIENT.xyz * 2.0);

				// Add all lights to the base color
				color *= finalLight;
				
				// Add fog to make it more moon like
				float distance = length(pos - _CamPos);

				fixed fogDensity = 0.1;
				const fixed3 fogColor = fixed3(0.8, 0.8, 0.8);

				// Fog fractions
				// Exponential
				float f = exp(-distance * fogDensity);

				// Exponential square
				// float f = exp(-distance * distance * fogDensity * fogDensity)
				color = (fogColor * (1.0 - f)) + (color * f);

				foxed4 finalColor = fixed4(color, 1.0);

				finalColor.a *= max(dot(lightDir, normal) * 1.0, 0.0);

				return finalColor;
			}

			fixed4 getColorFromRaymarch(float3 pos, float3 ray)
			{
				fixed4 color = 0;

				for (int i = 0; i < 64; i++)
				{
					float d = distFunc(pos);
					if(d < 0.005)
					{
						color = getColor(pos, fixed3(0.7, 0.7, 0.7));

						break;
					}
					if(d > 400.0)
					{
						break;
					}

					pos += ray * d * 0.5;
				}

				return color;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv * 2.0 - 1.0;

				float3 startPos = _CamPos;

				fixed focalLength = 0.62;

				fixed3 ray = normalize(_CampUp * uv.y + _CamRight * uv.x + _CamForward * focalLength);

				fixed4 color = getColorFromRaymarch(startPos, ray);

				return color;
			}

			ENDCG
		}
	}
}
