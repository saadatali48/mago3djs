'use strict';

var MagoRenderable = function() 
{
	this.objectsArray = [];
	this.meshArray = [];

	this.id;
	this.name;

	this.attributes = {
		isVisible: true
	};

	this.tMat;
	this.tMatOriginal;
    
	this.dirty = true;
	this.color4;
};

MagoRenderable.prototype.render = function(magoManager, shader, renderType, glPrimitive) 
{
	return abstract();
};
MagoRenderable.prototype.renderAsChild = function(magoManager, shader, renderType, glPrimitive) 
{
	return abstract();
};
MagoRenderable.prototype.makeMesh = function() 
{
	return abstract();
};
MagoRenderable.prototype.updateMatrix = function(ownerMatrix) 
{
	if (!ownerMatrix) 
	{
		if (this.geoLocDataManager === undefined || this.geoLocDataManager === null) 
		{
			return;
		}

		var geoLocDataManager = this.geoLocDataManager;
		var geoLocData = geoLocDataManager.getCurrentGeoLocationData();
		this.tMat = geoLocData.rotMatrix;
	}
	else 
	{
		this.tMat = this.tMatOriginal.getMultipliedByMatrix(ownerMatrix, this.tMat);
	}
    
	if (this.objectsArray === undefined)
	{ return; }
	for (var i=0, len=this.objectsArray.length; i <len;++i) 
	{
		var object = this.objectsArray[i];
		if (object instanceof MagoRenderable)
		{
			this.objectsArray[i].updateMatrix(this.tMat);
		}
	}
};
MagoRenderable.prototype.setDirty = function(dirty) 
{
	this.dirty = dirty;
};
/**
 * Set the unique one color of the box
 * @param {Number} r
 * @param {Number} g
 * @param {Number} b 
 * @param {Number} a
 */
MagoRenderable.prototype.setOneColor = function(r, g, b, a)
{
	// This function sets the unique one color of the mesh.***
	if (this.color4 === undefined)
	{ this.color4 = new Color(); }
	
	this.color4.setRGBA(r, g, b, a);
};