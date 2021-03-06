'use strict';

/**
 * mago3D 전체 환경 설정을 관리
 * @class MagoConfig
 */
var MagoConfig = {};

MagoConfig.getPolicy = function() 
{
	return this.serverPolicy;
};

MagoConfig.getData = function(key) 
{
	return this.dataObject[key];
};

MagoConfig.isDataExist = function(key) 
{
	return this.dataObject.hasOwnProperty(key);
};

MagoConfig.deleteData = function(key) 
{
	return delete this.dataObject[key];
};

/**
 * data 를 map에 저장
 * @param key map에 저장될 key
 * @param value map에 저장될 value
 */
MagoConfig.setData = function(key, value) 
{
	if (!this.isDataExist(key)) 
	{
		this.dataObject[key] = value;
	}
};

/**
 * F4D Converter 실행 결과물이 저장된 project data folder 명을 획득
 * @param projectDataFolder data folder
 */
MagoConfig.getProjectDataFolder = function(projectDataFolder) 
{
	var key = CODE.PROJECT_DATA_FOLDER_PREFIX + projectDataFolder;
	return this.dataObject[key];
};

/**
 * project map에 data folder명의 존재 유무를 검사
 * @param projectDataFolder
 */
MagoConfig.isProjectDataFolderExist = function(projectDataFolder) 
{
	var key = CODE.PROJECT_DATA_FOLDER_PREFIX + projectDataFolder;
	return this.dataObject.hasOwnProperty(key);
};

/**
 * project data folder명을 map에서 삭제
 * @param projectDataFolder
 */
MagoConfig.deleteProjectDataFolder = function(projectDataFolder) 
{
	var key = CODE.PROJECT_DATA_FOLDER_PREFIX + projectDataFolder;
	return delete this.dataObject[key];
};

/**
 * project data folder명을 Object에서 삭제
 * @param projectDataFolder Object에 저장될 key
 * @param value Object에 저장될 value
 */
MagoConfig.setProjectDataFolder = function(projectDataFolder, value) 
{
	var key = CODE.PROJECT_DATA_FOLDER_PREFIX + projectDataFolder;
	if (!this.isProjectDataFolderExist(key))
	{
		this.dataObject[key] = value;
	}
};

/**
 * 환경설정 초기화
 * @param serverPolicy mago3d policy(json)
 * @param projectIdArray data 정보를 map 저장할 key name
 * @param projectDataArray data 정보(json)
 */
MagoConfig.init = function(serverPolicy, projectIdArray, projectDataArray) 
{
	this.dataObject = {};
	
	this.selectHistoryObject = {};
	this.movingHistoryObject = {};
	this.colorHistoryObject = {};
	this.locationAndRotationHistoryObject = {};
	
	this.serverPolicy = serverPolicy;
	if (projectIdArray !== null && projectIdArray.length > 0) 
	{
		for (var i=0; i<projectIdArray.length; i++) 
		{
			if (!this.isDataExist(CODE.PROJECT_ID_PREFIX + projectIdArray[i])) 
			{
				this.setData(CODE.PROJECT_ID_PREFIX + projectIdArray[i], projectDataArray[i]);
				this.setProjectDataFolder(CODE.PROJECT_DATA_FOLDER_PREFIX + projectDataArray[i].data_key, projectDataArray[i].data_key);
			}
		}
	}
};

/**
 * 모든 데이터를 삭제함
 */
MagoConfig.clearAllData = function() 
{
	this.dataObject = {};
};

/**
 * 모든 선택 히스토리 삭제
 */
MagoConfig.clearSelectHistory = function() 
{
	this.selectHistoryObject = {};
};

/**
 * 모든 object 선택 내용 이력을 취득
 */
MagoConfig.getAllSelectHistory = function()
{
	return this.selectHistoryObject;
};

/**
 * project 별 해당 키에 해당하는 모든 object 선택 내용 이력을 취득
 */
MagoConfig.getSelectHistoryObjects = function(projectId, dataKey)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.selectHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	return dataKeyObject;
};

/**
 * object 선택 내용 이력을 취득
 */
MagoConfig.getSelectHistoryObject = function(projectId, dataKey, objectIndexOrder)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.selectHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined) { return undefined; }
	// objectIndexOrder 를 저장
	return dataKeyObject[objectIndexOrder];
};

/**
 * object 선택 내용을 저장
 */
MagoConfig.saveSelectHistory = function(projectId, dataKey, objectIndexOrder, changeHistory) 
{
	// projectId 별 Object을 검사
	var projectIdObject = this.selectHistoryObject.get(projectId);
	if (projectIdObject === undefined)
	{
		projectIdObject = {};
		this.selectHistoryObject[projectId] = projectIdObject;
	}
	
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined)
	{
		dataKeyObject = {};
		projectIdObject[dataKey] = dataKeyObject;
	}
	
	// objectIndexOrder 를 저장
	dataKeyObject[objectIndexOrder] = changeHistory;
};

/**
 * object 선택 내용을 삭제
 */
MagoConfig.deleteSelectHistoryObject = function(projectId, dataKey, objectIndexOrder)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.selectHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined) { return undefined; }
	// objectIndexOrder 를 저장
	return delete dataKeyObject[objectIndexOrder];
};

/**
 * 모든 이동 히스토리 삭제
 */
MagoConfig.clearMovingHistory = function() 
{
	this.movingHistoryObject = {};
};

/**
 * 모든 object 선택 내용 이력을 취득
 */
MagoConfig.getAllMovingHistory = function()
{
	return this.movingHistoryObject;
};

/**
 * project별 입력키 값과 일치하는 object 이동 내용 이력을 취득
 */
MagoConfig.getMovingHistoryObjects = function(projectId, dataKey)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.movingHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	return dataKeyObject;
};

/**
 * object 이동 내용 이력을 취득
 */
MagoConfig.getMovingHistoryObject = function(projectId, dataKey, objectIndexOrder)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.movingHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined) { return undefined; }
	// objectIndexOrder 를 저장
	return dataKeyObject[objectIndexOrder];
};

/**
 * object 이동 내용을 저장
 */
MagoConfig.saveMovingHistory = function(projectId, dataKey, objectIndexOrder, changeHistory) 
{
	// projectId 별 Object을 검사
	var projectIdObject = this.movingHistoryObject[projectId];
	if (projectIdObject === undefined)
	{
		projectIdObject = {};
		this.movingHistoryObject[projectId] = projectIdObject;
	}
	
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined)
	{
		dataKeyObject = {};
		projectIdObject[dataKey] = dataKeyObject;
	}
	
	// objectIndexOrder 를 저장
	dataKeyObject[objectIndexOrder] = changeHistory;
};

/**
 * object 이동 내용을 삭제
 */
MagoConfig.deleteMovingHistoryObject = function(projectId, dataKey, objectIndexOrder)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.movingHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined) { return undefined; }
	// objectIndexOrder 를 저장
	return delete dataKeyObject[objectIndexOrder];
};

/**
 * 모든 색깔 변경 이력을 획득
 */
MagoConfig.getAllColorHistory = function() 
{
	return this.colorHistoryObject;
};

/**
 * 모든 색깔변경 히스토리 삭제
 */
MagoConfig.clearColorHistory = function() 
{
	this.colorHistoryObject = {};
};

/**
 * project별 키에 해당하는 모든 색깔 변경 이력을 획득
 */
MagoConfig.getColorHistorys = function(projectId, dataKey)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.colorHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	return dataKeyObject;
};

/**
 * 색깝 변경 이력을 획득
 */
MagoConfig.getColorHistory = function(projectId, dataKey, objectId)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.colorHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined) { return undefined; }
	// objectId 를 저장
	return dataKeyObject[objectId];
};

/**
 * 색깝 변경 내용을 저장
 */
MagoConfig.saveColorHistory = function(projectId, dataKey, objectId, changeHistory) 
{
	// projectId 별 Object을 검사
	var projectIdObject = this.colorHistoryObject[projectId];
	if (projectIdObject === undefined)
	{
		projectIdObject = {};
		this.colorHistoryObject[projectId] = projectIdObject;
	}
	
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined)
	{
		dataKeyObject = {};
		projectIdObject[dataKey] = dataKeyObject;
	}

	if (objectId === null || objectId === "") 
	{
		dataKeyObject[dataKey] = changeHistory;
	}
	else 
	{
		dataKeyObject[objectId] = changeHistory;
	}
};

/**
 * 색깔 변경 이력을 삭제
 */
MagoConfig.deleteColorHistory = function(projectId, dataKey, objectId)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.colorHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined) { return undefined; }
	// objectIndexOrder 를 저장
	return delete dataKeyObject[objectId];
};

/**
 * 모든 색깔변경 히스토리 삭제
 */
MagoConfig.clearColorHistory = function() 
{
	this.colorHistoryObject = {};
};

/**
 * 모든 location and rotation 변경 이력을 획득
 */
MagoConfig.getAllLocationAndRotationHistory = function() 
{
	return this.locationAndRotationHistoryObject;
};

/**
 * 프로젝트별 해당 키 값을 갖는 모든 location and rotation 이력을 획득
 */
MagoConfig.getLocationAndRotationHistorys = function(projectId, dataKey)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.locationAndRotationHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	return dataKeyObject;
};

/**
 * location and rotation 이력을 획득
 */
MagoConfig.getLocationAndRotationHistory = function(projectId, dataKey)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.locationAndRotationHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	
	return dataKeyObject;
};

/**
 * location and rotation 내용을 저장
 */
MagoConfig.saveLocationAndRotationHistory = function(projectId, dataKey, changeHistory) 
{
	// projectId 별 Object을 검사
	var projectIdObject = this.locationAndRotationHistoryObject[projectId];
	if (projectIdObject === undefined)
	{
		projectIdObject = {};
		this.locationAndRotationHistoryObject[projectId] = projectIdObject;
	}
	
	// dataKey 별 Object을 검사
	var dataKeyObject = projectIdObject[dataKey];
	if (dataKeyObject === undefined)
	{
		dataKeyObject = {};
	}

	dataKeyObject[dataKey] = changeHistory;
};

/**
 * location and rotation 이력을 삭제
 */
MagoConfig.deleteLocationAndRotationHistory = function(projectId, dataKey)
{
	// projectId 별 Object을 검사
	var projectIdObject = this.locationAndRotationHistoryObject[projectId];
	if (projectIdObject === undefined) { return undefined; }
	// dataKey 별 Object을 검사
	var dataKeyObject = delete projectIdObject[dataKey];
};

/**
 * 모든 location and rotation 히스토리 삭제
 */
MagoConfig.clearLocationAndRotationHistory = function() 
{
	this.locationAndRotationHistoryObject = {};
};
	
/**
 * TODO 이건 나중에 활요. 사용하지 않음
 * check 되지 않은 데이터들을 삭제함
 * @param keyObject 비교할 맵
 */
/*MagoConfig.clearUnSelectedData = function(keyObject)
{
	for (var key of this.dataObject.keys())
	{
		if (!keyObject.hasxxxxx(key))
		{
			// data folder path가 존재하면....
			if (key.indexOf(CODE.PROJECT_DATA_FOLDER_PREFIX) >= 0) 
			{
				// 지우는 처리가 있어야 함
			}
			this.dataObject.delete(key);
		}
	}
};*/
