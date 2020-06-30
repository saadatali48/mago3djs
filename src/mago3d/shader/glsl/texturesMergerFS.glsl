#ifdef GL_ES
    precision highp float;
#endif

uniform sampler2D texture_0;  
uniform sampler2D texture_1;
uniform sampler2D texture_2;
uniform sampler2D texture_3;
uniform sampler2D texture_4;
uniform sampler2D texture_5;
uniform sampler2D texture_6;
uniform sampler2D texture_7;

uniform float externalAlphasArray[8];
uniform int uActiveTextures[8];
uniform vec4 uExternalTexCoordsArray[8]; // vec4 (minS, minT, maxS, maxT).
uniform vec2 uMinMaxAltitudes; // used for altitudes textures as bathymetry.

varying vec2 v_tex_pos;

vec3 getRainbowColor_byHeight(float height, float minHeight, float maxHeight)
{
	float minHeight_rainbow = minHeight;
	float maxHeight_rainbow = maxHeight;
	
	float gray = (height - minHeight_rainbow)/(maxHeight_rainbow - minHeight_rainbow);
	if (gray > 1.0){ gray = 1.0; }
	else if (gray<0.0){ gray = 0.0; }
	
	float r, g, b;
	
	if(gray < 0.16666)
	{
		b = 0.0;
		g = gray*6.0;
		r = 1.0;
	}
	else if(gray >= 0.16666 && gray < 0.33333)
	{
		b = 0.0;
		g = 1.0;
		r = 2.0 - gray*6.0;
	}
	else if(gray >= 0.33333 && gray < 0.5)
	{
		b = -2.0 + gray*6.0;
		g = 1.0;
		r = 0.0;
	}
	else if(gray >= 0.5 && gray < 0.66666)
	{
		b = 1.0;
		g = 4.0 - gray*6.0;
		r = 0.0;
	}
	else if(gray >= 0.66666 && gray < 0.83333)
	{
		b = 1.0;
		g = 0.0;
		r = -4.0 + gray*6.0;
	}
	else if(gray >= 0.83333)
	{
		b = 6.0 - gray*6.0;
		g = 0.0;
		r = 1.0;
	}
	
	float aux = r;
	r = b;
	b = aux;
	
	//b = -gray + 1.0;
	//if (gray > 0.5)
	//{
	//	g = -gray*2.0 + 2.0; 
	//}
	//else 
	//{
	//	g = gray*2.0;
	//}
	//r = gray;
	vec3 resultColor = vec3(r, g, b);
    return resultColor;
} 

vec3 getWhiteToBlueColor_byHeight(float height, float minHeight, float maxHeight)
{
    // White to Blue in 32 steps.
    float gray = (height - minHeight)/(maxHeight - minHeight);
    //gray = 1.0 - gray; // invert gray value (white to blue).
    // calculate r, g, b values by gray.

    float r, g, b;

    // Red.
    if(gray >= 0.0 && gray < 0.15625) // [1, 5] from 32 divisions.
    {
        float minGray = 0.0;
        float maxGray = 0.15625;
        //float maxR = 0.859375; // 220/256.
        float maxR = 1.0;
        float minR = 0.3515625; // 90/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        r = maxR - relativeGray*(maxR - minR);
    }
    else if(gray >= 0.15625 && gray < 0.40625) // [6, 13] from 32 divisions.
    {
        float minGray = 0.15625;
        float maxGray = 0.40625;
        float maxR = 0.3515625; // 90/256.
        float minR = 0.0; // 0/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        r = maxR - relativeGray*(maxR - minR);
    }
    else  // [14, 32] from 32 divisions.
    {
        r = 0.0;
    }

    // Green.
    if(gray >= 0.0 && gray < 0.15625) // [1, 5] from 32 divisions.
    {
        g = 1.0; // 256.
    }
    else if(gray >= 0.15625 && gray < 0.5625) // [6, 18] from 32 divisions.
    {
        float minGray = 0.15625;
        float maxGray = 0.5625;
        float maxG = 1.0; // 256/256.
        float minG = 0.0; // 0/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        g = maxG - relativeGray*(maxG - minG);
    }
    else  // [18, 32] from 32 divisions.
    {
        g = 0.0;
    }

    // Blue.
    if(gray < 0.5625)
    {
        b = 1.0;
    }
    else // gray >= 0.5625 && gray <= 1.0
    {
        float minGray = 0.5625;
        float maxGray = 1.0;
        float maxB = 1.0; // 256/256.
        float minB = 0.0; // 0/256.
        float relativeGray = (gray- minGray)/(maxGray - minGray);
        b = maxB - relativeGray*(maxB - minB);
    }

    return vec3(r, g, b);
}

//vec4 mixColor(sampler2D tex)
bool intersects(vec2 texCoord, vec4 extension)
{
    bool bIntersects = true;
    float minS = extension.x;
    float minT = extension.y;
    float maxS = extension.z;
    float maxT = extension.w;

    if(texCoord.x < minS || texCoord.x > maxS)
    return false;
    else if(texCoord.y < minT || texCoord.y > maxT)
    return false;

    return bIntersects;
}

void getTextureColor(in int activeNumber, in vec4 currColor4, in vec2 texCoord,  inout bool victory, in float externalAlpha, in vec4 externalTexCoords, inout vec4 resultTextureColor)
{
    if(activeNumber == 1 || activeNumber == 2)
    {
        if(currColor4.w > 0.0 && externalAlpha > 0.0)
        {
            if(victory)
            {
                resultTextureColor = mix(resultTextureColor, currColor4, currColor4.w*externalAlpha);
            }
            else{
                currColor4.w *= externalAlpha;
                resultTextureColor = currColor4;
            }
            
            victory = true;
        }
    }
    else if(activeNumber == 10)
    {
        // Bathymetry texture.
        float altitude = 1000000.0;
        if(currColor4.w > 0.0)
        {
            // decode the grayScale.***
            altitude = uMinMaxAltitudes.x + currColor4.r * (uMinMaxAltitudes.y - uMinMaxAltitudes.x);
        
            if(altitude < 0.0)
            {
                /*
                float minHeight_rainbow = uMinMaxAltitudes.x;
                float maxHeight_rainbow = 0.0;
                float gray = (altitude - minHeight_rainbow)/(maxHeight_rainbow - minHeight_rainbow);
                vec4 seaColor;

                float red = gray + 0.1;//float red = gray + 0.2;
                float green = gray + 0.5;//float green = gray + 0.6;
                float blue = gray*2.0 + 2.0;
                seaColor = vec4(red, green, blue, 1.0);
                */
                vec3 seaColorRGB = getWhiteToBlueColor_byHeight(altitude, 0.0, uMinMaxAltitudes.x);
                vec4 seaColor = vec4(seaColorRGB, 1.0);
                
                resultTextureColor = mix(resultTextureColor, seaColor, 0.99); 
            }
        }
    }
}

void main()
{           
    // Debug.
    /*
    if(v_tex_pos.x < 0.004 || v_tex_pos.x > 0.996)
    {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }

    if(v_tex_pos.y < 0.004 || v_tex_pos.y > 0.996)
    {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        return;
    }
    */

    vec2 texCoord = vec2(1.0 - v_tex_pos.x, 1.0 - v_tex_pos.y);

    // Take the base color.
    vec4 textureColor = vec4(0.0, 0.0, 0.0, 0.0);
    bool victory = false;

    if(uActiveTextures[0] > 0)
    {
        if(uActiveTextures[0] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[0];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[0], texture2D(texture_0, texCoord), texCoord,  victory, externalAlphasArray[0], uExternalTexCoordsArray[0], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[0], texture2D(texture_0, texCoord), texCoord,  victory, externalAlphasArray[0], uExternalTexCoordsArray[0], textureColor);
        
    }
    if(uActiveTextures[1] > 0)
    {
        if(uActiveTextures[1] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[1];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[1], texture2D(texture_1, texCoord), texCoord,  victory, externalAlphasArray[1], uExternalTexCoordsArray[1], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[1], texture2D(texture_1, texCoord), texCoord,  victory, externalAlphasArray[1], uExternalTexCoordsArray[1], textureColor);
    }
    if(uActiveTextures[2] > 0)
    {
        if(uActiveTextures[2] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[2];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[2], texture2D(texture_2, texCoord), texCoord,  victory, externalAlphasArray[2], uExternalTexCoordsArray[2], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[2], texture2D(texture_2, texCoord), texCoord,  victory, externalAlphasArray[2], uExternalTexCoordsArray[2], textureColor);
    }
    if(uActiveTextures[3] > 0)
    {
        if(uActiveTextures[3] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[3];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[3], texture2D(texture_3, texCoord), texCoord,  victory, externalAlphasArray[3], uExternalTexCoordsArray[3], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[3], texture2D(texture_3, texCoord), texCoord,  victory, externalAlphasArray[3], uExternalTexCoordsArray[3], textureColor);
    }
    if(uActiveTextures[4] > 0)
    {
        if(uActiveTextures[4] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[4];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[4], texture2D(texture_4, texCoord), texCoord,  victory, externalAlphasArray[4], uExternalTexCoordsArray[4], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[4], texture2D(texture_4, texCoord), texCoord,  victory, externalAlphasArray[4], uExternalTexCoordsArray[4], textureColor);
    }
    if(uActiveTextures[5] > 0)
    {
        if(uActiveTextures[5] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[5];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[5], texture2D(texture_5, texCoord), texCoord,  victory, externalAlphasArray[5], uExternalTexCoordsArray[5], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[5], texture2D(texture_5, texCoord), texCoord,  victory, externalAlphasArray[5], uExternalTexCoordsArray[5], textureColor);
    }
    if(uActiveTextures[6] > 0)
    {
        if(uActiveTextures[6] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[6];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[6], texture2D(texture_2, texCoord), texCoord,  victory, externalAlphasArray[6], uExternalTexCoordsArray[6], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[6], texture2D(texture_2, texCoord), texCoord,  victory, externalAlphasArray[6], uExternalTexCoordsArray[6], textureColor);
    }
    if(uActiveTextures[7] > 0)
    {
        if(uActiveTextures[7] == 2)
        {
            // CustomImage. Must recalculate texCoords.
            vec4 externalTexCoord = uExternalTexCoordsArray[7];
            
            // check if intersects.
            vec2 texCoordAux = vec2(texCoord.x, 1.0-texCoord.y);
            if(intersects(texCoordAux, externalTexCoord))
            {
                // convert myTexCoord to customImageTexCoord.
                vec2 minTexCoord = vec2(externalTexCoord.x, externalTexCoord.y);
                vec2 maxTexCoord = vec2(externalTexCoord.z, externalTexCoord.w);

                texCoord.x = (texCoordAux.x - minTexCoord.x)/(maxTexCoord.x - minTexCoord.x);
                texCoord.y = (texCoordAux.y - minTexCoord.y)/(maxTexCoord.y - minTexCoord.y);

                texCoord.y = 1.0 - texCoord.y;
                getTextureColor(uActiveTextures[7], texture2D(texture_7, texCoord), texCoord,  victory, externalAlphasArray[7], uExternalTexCoordsArray[7], textureColor);
            }
        }
        else
            getTextureColor(uActiveTextures[7], texture2D(texture_7, texCoord), texCoord,  victory, externalAlphasArray[7], uExternalTexCoordsArray[7], textureColor);
    }
    
    if(!victory)
    discard;
    
    gl_FragColor = textureColor;
	
}