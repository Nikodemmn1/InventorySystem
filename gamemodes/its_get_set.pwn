#define Its_GetCategoryInfo(%1,%2) __ItsGetCategoryInfo(%1, %2, #%2)
__ItsGetCategoryInfo(categoryID, valType, const valTypeStr[])
{
    if(strfind(valTypeStr, "ITS_CAT_") == 0)
    { 
        return itsCategories[categoryID][e_ITS_CATEGORY:valType];
    }
    else if(strfind(valTypeStr, "ITS_FUNC_") == 0)
    {
        return itsCategories[categoryID][ITS_FUNCTIONS][e_ITS_FUNCTIONS:valType];
    }

    itsNotExist = true;
    return 0;
}

#define Its_GetCategoryInfoArr(%1,%2) __ItsGetCategoryInfoArr(%1, %2, #%2)
__ItsGetCategoryInfoArr(categoryID, valType, const valTypeStr[], outputStr[], outputSize)
{
    if(strfind(valTypeStr, "ITS_CAT_") == 0)
    { 
        strcopy(outputStr, itsCategories[categoryID][e_ITS_CATEGORY:valType], outputSize);
        return 1;
    }

    itsNotExist = true;
    return 0;
}

__ItsGetSet_Mutual(dbID, const valTypeStr[], const tagPrefix[ITS_CAT_TAG_SIZE] = "ITS_")
{
    new tag[ITS_CAT_TAG_SIZE], formatString[96];

    format(formatString, sizeof(formatString), "'%s'p<_>s["#ITS_CAT_TAG_SIZE"]{s[1000]}p< >{S[1000]}", tagPrefix);
    sscanf(valTypeStr, formatString, tag);
    if(!map_has_str_key(itsCategoryIDByTag, tag))
    {
        printf("__ItsGet() - nieprawid³owy tag %s!", tag);
        SendRconCommand("exit");
        return -1;
    }

    new categoryID = map_str_get(itsCategoryIDByTag, tag);

    if(!map_has_key(itsCategories[categoryID][ITS_IDXMAP], dbID))
    {
        itsNotExist = true;
        return -1;
    }

    itsNotExist = false;
    return categoryID;
}

#define Its_Get(%1,%2) __ItsGet(%1, %2, #%2)
__ItsGet(dbID, valType, const valTypeStr[])
{
    new tagPrefix[ITS_CAT_TAG_SIZE] = "ITS_", isClass = false;

    if(strcmp(valTypeStr, "ITS_CL_IC_MODELID") == 0)
    {
        new specialModelID = Its_Get(dbID, ITS_SPMOD_MODELID);
        if(!itsNotExist)
        {
            return specialModelID;
        }
    }

    if(strfind(valTypeStr, "ITS_CAT_") == 0)
    { 
        new categoryID = Its_Get(dbID, ITS_CL_IC_CATEGORY);
        return itsCategories[categoryID][e_ITS_CATEGORY:valType];
    }
    else if(strfind(valTypeStr, "ITS_FUNC_") == 0)
    {
        new categoryID = Its_Get(dbID, ITS_CL_IC_CATEGORY);
        return itsCategories[categoryID][ITS_FUNCTIONS][e_ITS_FUNCTIONS:valType];
    }
    else if(strfind(valTypeStr, "ITS_CL_") == 0)
    {
        isClass = true;
        tagPrefix = "ITS_CL_";
    }

    new cID = __ItsGetSet_Mutual(dbID, valTypeStr, tagPrefix);

    if(cID == -1)
    {
        return 0;
    }

    if(isClass)
    {
        new classID = Its_Get(dbID, ITS_IC_CLASSID);
        new classArrayAddr = itsCategories[cID][ITS_CLASSES_ARRAY_AMX_ADDR];
        return ReadAmxMemory(classArrayAddr + cellbytes * (itsCategories[cID][ITS_CLASS_ELEM_SIZE] * classID + valType));
    }

    return MEM_UM_get_val(itsCategories[cID][ITS_ARR], map_get(itsCategories[cID][ITS_IDXMAP], dbID) * itsCategories[cID][ITS_ELEM_SIZE] + valType);
}

//TODO: PRZETESTOWAÆ TO
#define Its_GetArr(%1,%2,%3,%4) __ItsGetArr(%1, %2, #%2, %3, %4)
__ItsGetArr(dbID, valType, const valTypeStr[], outputStr[], outputSize)
{
    new tagPrefix[ITS_CAT_TAG_SIZE] = "ITS_", isClass = false;

    if(strfind(valTypeStr, "ITS_CAT_") == 0)
    { 
        new categoryID = Its_Get(dbID, ITS_CL_IC_CATEGORY);
        strcopy(outputStr, itsCategories[categoryID][e_ITS_CATEGORY:valType], outputSize);
        return 1;
    }
    else if(strfind(valTypeStr, "ITS_CL_") == 0)
    {
        isClass = true;
        tagPrefix = "ITS_CL_";
    }

    new cID = __ItsGetSet_Mutual(dbID, valTypeStr, tagPrefix);
    
    if(cID == -1)
    {
        return 0;
    }

    if(isClass)
    {
        new classID = Its_Get(dbID, ITS_IC_CLASSID);
        new classArrayAddr = itsCategories[cID][ITS_CLASSES_ARRAY_AMX_ADDR];
        ReadAmxMemoryArray(classArrayAddr + cellbytes * (itsCategories[cID][ITS_CLASS_ELEM_SIZE] * classID + valType), outputStr, outputSize);
        return 1;
    }

    MEM_UM_get_arr(itsCategories[cID][ITS_ARR], 
        map_get(itsCategories[cID][ITS_IDXMAP], dbID) * itsCategories[cID][ITS_ELEM_SIZE] + valType, 
        outputStr, 
        outputSize);
    return 1;
}

#define Its_Set(%1,%2,%3) __ItsSet(%1, %2, #%2, _:%3)
__ItsSet(dbID, valType, const valTypeStr[], newVal)
{
    new cID = __ItsGetSet_Mutual(dbID, valTypeStr);
    
    if(cID == -1)
    {
        return 0;
    }

    map_add(itsCategories[cID][ITS_UPDATE_DIRTY], dbID, true);
    MEM_UM_set_val(itsCategories[cID][ITS_ARR], map_get(itsCategories[cID][ITS_IDXMAP], dbID) * itsCategories[cID][ITS_ELEM_SIZE] + valType, newVal);
    return 1;
}

//TODO: PRZETESTOWAÆ TO
#define Its_SetArr(%1,%2,%3,%4) __ItsSetArr(%1, %2, #%2, %3, %4)
__ItsSetArr(dbID, valType, const valTypeStr[], newVal[], valSize = sizeof newVal)
{
    new cID = __ItsGetSet_Mutual(dbID, valTypeStr);
    
    if(cID == -1)
    {
        return 0;
    }

    map_add(itsCategories[cID][ITS_UPDATE_DIRTY], dbID, true);
    MEM_UM_set_arr(itsCategories[cID][ITS_ARR], 
        map_get(itsCategories[cID][ITS_IDXMAP], dbID) * itsCategories[cID][ITS_ELEM_SIZE] + valType, 
        newVal, 
        valSize);
    return 1;
}