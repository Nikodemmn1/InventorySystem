#include <YSI\y_hooks>

mysql_real_escape_string_ITS(const source[],destination[],connectionHandle = 1)
{
    strcat(destination, source, 65536);
    strreplace(destination, #ITS_ITEMS_DELIMITER_S, "", false, 0, -1, 65536);
    strreplace(destination, #ITS_IC_POS_DELIMITER_S, "", false, 0, -1, 65536);
    strreplace(destination, #ITS_PC_DELIMITER_S, "", false, 0, -1, 65536);

	return mysql_real_escape_string(destination, destination, connectionHandle = 1);
}
#if defined _ALS_mysql_real_escape_string
    #undef mysql_real_escape_string
#else
    #define _ALS_mysql_real_escape_string
#endif
#define mysql_real_escape_string mysql_real_escape_string_ITS

hook OnGameModeInit()
{
    CA_Init();
    ME_Mysql_Connect();
    Its_Init();

    return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnGameModeExit()
{
    Its_MassUpdate();
    Its_MassDeleteMysql();
    Its_Destroy();

    return Y_HOOKS_CONTINUE_RETURN_1;
}

ME_Mysql_Connect()
{
    new mysqlHost[32], mysqlUser[128], mysqlDb[128], mysqlPass[128];
	new mysqlConfFName[32] =  "mysql.ini"
	if(dini_Exists(mysqlConfFName)) 
	{
		strcat(mysqlHost, dini_Get(mysqlConfFName, "Host"));
		strcat(mysqlUser, dini_Get(mysqlConfFName, "User"));
		strcat(mysqlDb, dini_Get(mysqlConfFName, "DB"));
		strcat(mysqlPass, dini_Get(mysqlConfFName, "Pass"));
	}
    else
    {
        print("MYSQL: Brak pliku konfiguracyjnego mysql.ini!");
		SendRconCommand("exit");
		return 0;
    }

    mysql_connect(mysqlHost, mysqlUser, mysqlDb, mysqlPass);

    print(" ");
	if(mysql_ping() == 1)
	{
		print("MYSQL: Polaczono sie z baza MySQL");
	}
	else
	{
		print("MYSQL: Nieudane polaczenie z baza MySQL");
		SendRconCommand("gamemodetext Brak polaczenia MySQL");
		SendRconCommand("exit");
		return 0;
	}
	
	mysql_query("SET NAMES 'cp1250'");
	return 1;
}

Its_CategoryInfo_Destroy(const itsCategoryInfo[e_ITS_CATEGORY])
{
    MEM_UM_delete(itsCategoryInfo[ITS_ARR]);
    list_delete(itsCategoryInfo[ITS_SQL_COLUMNS]);
    map_delete(itsCategoryInfo[ITS_IDXMAP]);
    list_delete(itsCategoryInfo[ITS_HOLES]);
    map_delete(itsCategoryInfo[ITS_UPDATE_DIRTY]);
    list_delete(itsCategoryInfo[ITS_TO_DELETE]);
    list_delete(itsCategoryInfo[ITS_TO_INSERT_ADDITIONAL]);

    return 1;
}

Its_CategoryFuncs_Construct(const tag[], Func:loadRowFunc<s>, Func:deleteFunc<d>, Func:updateQBuildFunc<dddas>, Func:insertUpdateIDFunc<dd>, Func:insertQBuildFunc<dsd>, Func:unloadFunc<dd>)
{
    new catFunc[e_ITS_FUNCTIONS];
    catFunc[ITS_FUNC_READ_ROW] = loadRowFunc;
    catFunc[ITS_FUNC_DELETE] = deleteFunc;
    catFunc[ITS_FUNC_UPDATE_QBUILD] = updateQBuildFunc;
    catFunc[ITS_FUNC_INSERT_UPDATE_ID] = insertUpdateIDFunc;
    catFunc[ITS_FUNC_INSERT_QBUILD] = insertQBuildFunc;
    catFunc[ITS_FUNC_UNLOAD] = unloadFunc;
    map_str_add_arr(itsFunctionsByTag, tag, catFunc);
    return 1;
}

Its_Init_Custom_Rot()
{
    itsCustomRotationsForModels = map_new();
    map_add_arr(itsCustomRotationsForModels, 19559, {270.0, 90.0, 0.0});
    return 1;
}

Its_Get_Custom_Rot(modelID, &Float:rotX, &Float:rotY, &Float:rotZ)
{
    new Float:rots[e_ITS_ROTATIONS] = {Float:0, ...};

    if(map_has_key(itsCustomRotationsForModels, modelID))
    {
        map_get_arr(itsCustomRotationsForModels, modelID, rots);
    }

    rotX = rots[ITS_ROT_X];
    rotY = rots[ITS_ROT_X];
    rotZ = rots[ITS_ROT_X];
    
    return 1;
}

#pragma warning push
#pragma warning disable 202
#pragma warning disable 213
Its_Init()
{
    itsCategoryIDByTag = map_new();
    itsCategoriesHierarchy = list_new();
    itsElemSizeByTag = map_new();
    itsClassElemSizeByTag = map_new();
    itsFunctionsByTag = map_new();
    itsClassArrAmxAddrByTag = map_new();

    itsObjectIDToDbID = map_new();
    its3DTextIDToDbID = map_new();

    map_str_add(itsElemSizeByTag, "IC", _:e_ITS_ITEM_OR_CONTAINER);
    map_str_add(itsElemSizeByTag, "BC", _:e_ITS_BASIC_CONTAINER);
    map_str_add(itsElemSizeByTag, "BI", _:e_ITS_BASIC_ITEM);
    map_str_add(itsElemSizeByTag, "POS", _:e_ITS_IC_POS);
    map_str_add(itsElemSizeByTag, "PC", _:e_ITS_PLAYER_CONTAINER);
    map_str_add(itsElemSizeByTag, "SPMOD", _:e_ITS_SPECIAL_MODEL);

    Its_CategoryFuncs_Construct("IC", 
        addressof(Its_Load_Row_IC<s>), 
        addressof(Its_Delete_IC<d>), 
        addressof(Its_IC_UpdQBuild<dddas>), 
        addressof(Its_MassInsertIdUpdate_IC<dd>),
        addressof(Its_IC_InsQBuild<dsd>),
        addressof(Its_Unload_IC<dd>));
    Its_CategoryFuncs_Construct("BC",
        Func:0<s>, 
        addressof(Its_Delete_BC<d>), 
        Func:0<dddas>,
        addressof(Its_MassInsertIdUpdate_BC<dd>),
        Func:0<dsd>,
        addressof(Its_Unload_BC<dd>));
    Its_CategoryFuncs_Construct("BI", 
        addressof(Its_Load_Row_BI<s>), 
        addressof(Its_Delete_BI<d>), 
        addressof(Its_BI_UpdQBuild<dddas>),
        addressof(Its_MassInsertIdUpdate_BI<dd>),
        addressof(Its_BI_InsQBuild<dsd>),
        addressof(Its_Unload_BI<dd>));
    Its_CategoryFuncs_Construct("POS", 
        addressof(Its_Load_Row_POS<s>), 
        addressof(Its_Delete_POS<d>), 
        addressof(Its_POS_UpdQBuild<dddas>),
        Func:0<dd>,
        addressof(Its_POS_InsQBuild<dsd>),
        addressof(Its_Unload_POS<dd>));
    Its_CategoryFuncs_Construct("PC", 
        addressof(Its_Load_Row_PC<s>), 
        addressof(Its_Delete_PC<d>), 
        addressof(Its_PC_UpdQBuild<dddas>),
        Func:0<dd>,
        addressof(Its_PC_InsQBuild<dsd>),
        addressof(Its_Unload_PC<dd>));
    Its_CategoryFuncs_Construct("SPMOD", 
        addressof(Its_Load_Row_SPMOD<s>), 
        addressof(Its_Delete_SPMOD<d>), 
        addressof(Its_SPMOD_UpdQBuild<dddas>),
        Func:0<dd>,
        addressof(Its_SPMOD_InsQBuild<dsd>),
        addressof(Its_Unload_SPMOD<dd>));

    map_str_add(itsClassArrAmxAddrByTag, "IC", ref(itsClassesIC[0]));
    map_str_add(itsClassArrAmxAddrByTag, "BC", ref(itsClassesBC[0]));
    map_str_add(itsClassArrAmxAddrByTag, "BI", ref(itsClassesBI[0]));

    map_str_add(itsClassElemSizeByTag, "IC", _:e_ITS_CLASS);
    map_str_add(itsClassElemSizeByTag, "BC", _:e_ITS_CONTAINER_CLASS);
    map_str_add(itsClassElemSizeByTag, "BI", _:e_ITS_ITEM_CLASS);

    Its_Init_Custom_Rot();

    Its_Load_Item_Categories();
    Its_Load_Classes();

    ////TODO: USUN!!!!!
    Its_Load_Player_Container(2);
    Its_Load_Player_Container(3);
    Its_Load_Player_Container(4);
    Its_Load_Placed();

    return 1;
}
#pragma warning pop

Its_Destroy()
{
    for(new Iter:icIter=map_iter(itsCategoriesByTag["IC"][ITS_IDXMAP]);iter_inside(icIter);iter_move_next(icIter))
    {
        new dbID = iter_get_key(icIter);
        if(Its_Get(dbID, ITS_IC_ISCONTAINER))
        {
            new List:itemList = List:Its_Get(dbID, ITS_BC_CONT_ITEMS);
            list_delete(itemList);
        }
    }

    for(new Iter:icIter=map_iter(itsCategoryIDByTag);iter_inside(icIter);iter_move_next(icIter))
    {
        new catID = iter_get(icIter);
        Its_CategoryInfo_Destroy(itsCategories[catID]);
    }

    map_delete(itsCategoryIDByTag);
    list_delete(itsCategoriesHierarchy);
    map_delete(itsElemSizeByTag);
    map_delete(itsClassElemSizeByTag);
    map_delete(itsFunctionsByTag);
    map_delete(itsClassArrAmxAddrByTag);

    map_delete(itsObjectIDToDbID);
    map_delete(its3DTextIDToDbID);

    map_delete(itsCustomRotationsForModels);
    
    return 1;
}

__Its_Append_To_Container(itemID, containerID)
{
    new oldContainerTakenSpace = Its_Get(containerID, ITS_BC_TAKEN_SPACE);
    new itemSize = Its_Get(itemID, ITS_CL_BI_ITEMSIZE);

    if(oldContainerTakenSpace + itemSize > Its_Get(containerID, ITS_CL_BC_CONTAINERSIZE))
    {
        return ITS_NOT_ENOUGH_SPACE;
    }

    new List:newContList = List:Its_Get(containerID, ITS_BC_CONT_ITEMS);
    list_add(newContList, itemID);
    Its_Set(itemID, ITS_BI_PARENTCONTAINER, containerID);
    Its_Set(containerID, ITS_BC_TAKEN_SPACE, oldContainerTakenSpace + itemSize);

    return 1;
}

__Its_Detach_From_Container(itemID, containerID)
{
    new List:oldContList = List:Its_Get(containerID, ITS_BC_CONT_ITEMS);
    list_remove(oldContList, list_find(oldContList, itemID));
    Its_Set(itemID, ITS_BI_PARENTCONTAINER, ITS_NULL);

    new newTakenSpace = Its_Get(containerID, ITS_BC_TAKEN_SPACE) - Its_Get(itemID, ITS_CL_BI_ITEMSIZE);
    Its_Set(containerID, ITS_BC_TAKEN_SPACE, newTakenSpace);

    return 1;
}

Its_Remove_Item_From_Container(itemDbId, oldContDbId = ITS_NULL)
{
    if(oldContDbId == ITS_NULL)
    {
        oldContDbId = Its_Get(itemDbId, ITS_BI_PARENTCONTAINER);
    }

    if(oldContDbId != ITS_NULL)
    {
        __Its_Detach_From_Container(itemDbId, oldContDbId);
    }

    return 1;
}

Its_Unplace(dbID)
{
    if(!map_has_key(itsCategoriesByTag["POS"][ITS_IDXMAP], dbID))
    {
        return 0;
    }

    new objectID = Its_Get(dbID, ITS_POS_OBJECTID);
    new Text3D:textID = Text3D:Its_Get(dbID, ITS_POS_3DTEXTID);

    if(objectID != ITS_NULL)
    {
        DestroyDynamicObject(objectID);
    }

    if(textID != Text3D:ITS_NULL)
    {
        DestroyDynamic3DTextLabel(textID);
    }

    Its_Delete_POS(dbID);
    return 1;
}

Its_Container_To_Empty_Item(containerID, newParentContainer)
{
    new emptyItemClass = Its_Get(containerID, ITS_CL_BC_EMPTYITEMCLASS);
    
    if(emptyItemClass == ITS_NULL)
    {
        return ITS_CONT_EMPTY_NOT_EXIST;
    }

    if(Its_Get(newParentContainer, ITS_BC_TAKEN_SPACE) + itsClassesBI[emptyItemClass][ITS_CL_BI_ITEMSIZE] > Its_Get(newParentContainer, ITS_CL_BC_CONTAINERSIZE))
    {
        return ITS_NOT_ENOUGH_SPACE;
    }

    Its_Create_BI(Its_Get(containerID, ITS_CL_BC_EMPTYITEMCLASS), false, newParentContainer);
    
    new Func:deleteFunc<d> = Func:Its_Get(containerID, ITS_FUNC_DELETE)<d>;
    @.deleteFunc(containerID);

    return 1;
}

Its_MoveAllBetweenContainers(oldContID, newContID)
{
    new List:oldContList = List:Its_Get(oldContID, ITS_BC_CONT_ITEMS);
    while(list_size(oldContList) != 0)
    {
        if(Its_Move_Item_To_Container(list_get(oldContList, 0), newContID) == ITS_NOT_ENOUGH_SPACE)
        {
            return ITS_NOT_ENOUGH_SPACE;
        }
    }

    return 1;
}

Its_Move_Item_To_Container(itemDbId, newContDbId)
{
    Its_Unplace(itemDbId);
    new oldContDbId = Its_Get(itemDbId, ITS_BI_PARENTCONTAINER);

    if(oldContDbId != newContDbId)
    {
        Its_Remove_Item_From_Container(itemDbId, oldContDbId);
        __Its_Append_To_Container(itemDbId, newContDbId);
    }

    return 1;
}

Its_Place_Item_Object(itemDbId, Float:x, Float:y, Float:z, interior, vw)
{
    CA_FindZ_For2DCoord(x, y, z);
    if(1 || Its_Get(itemDbId, ITS_CL_IC_ISPERSISTENT))
    {
        new Float:rotX, Float:rotY, Float:rotZ;
        new modelID = Its_Get(itemDbId, ITS_CL_IC_MODELID), Float:minZ, Float:tmp;
        CA_GetModelBoundingBox(modelID, tmp, tmp, minZ, tmp, tmp, tmp);
        z -= minZ;
        Its_Get_Custom_Rot(modelID, rotX, rotY, rotZ);
        new objectID = CreateDynamicObject(modelID, x, y, z, rotX, rotY, rotZ, vw, interior);
        map_add(itsObjectIDToDbID, objectID, itemDbId);
        Its_Set(itemDbId, ITS_POS_OBJECTID, objectID);
    }

    new fName[ITS_CAT_FRIENDLYNAME_SIZE], text[ITS_CAT_FRIENDLYNAME_SIZE*3];
    Its_GetArr(itemDbId, ITS_CL_IC_FRIENDLYNAME, fName, ITS_CAT_FRIENDLYNAME_SIZE);
    format(text, sizeof(text), "%s [ID: %d]", fName, itemDbId);

    if(Its_Get(itemDbId, ITS_IC_ISCONTAINER))
    {
        format(text, sizeof(text), "%s\n**pojemnik**", text);
    }

    new Text3D:text3dId = CreateDynamic3DTextLabel(text, 0xB4B5B7FF, x, y, z, 10.0);
    map_add(its3DTextIDToDbID, _:text3dId, itemDbId);
    Its_Set(itemDbId, ITS_POS_3DTEXTID, text3dId);

    return 1;
}

Its_Place_Item(itemDbId, Float:x, Float:y, Float:z, interior, vw, ownerID = ITS_NULL)
{
    if(map_has_key(itsCategoriesByTag["POS"][ITS_IDXMAP], itemDbId) || !Its_Get(itemDbId, ITS_CL_IC_ISPLACEABLE))
    {
        return 0;
    }

    if(!Its_Get(itemDbId, ITS_IC_ISCONTAINER) && Its_Get(itemDbId, ITS_CL_BI_RELCONTCLASS) != ITS_NULL)
    {
        new oldItemId = itemDbId;

        itemDbId = Its_Create_BC(Its_Get(itemDbId, ITS_CL_BI_RELCONTCLASS));

        Its_Remove_Item_From_Container(oldItemId);
        new Func:deleteFunc<d> = Func:Its_Get(oldItemId, ITS_FUNC_DELETE)<d>;
        @.deleteFunc(oldItemId);
    }

    if(!Its_Get(itemDbId, ITS_IC_ISCONTAINER))
    {
        Its_Remove_Item_From_Container(itemDbId);
    }

    Its_Create_POS(itemDbId, x, y, z, interior, vw, ownerID);
    Its_Place_Item_Object(itemDbId, x, y, z, interior, vw);

    return 1;
}