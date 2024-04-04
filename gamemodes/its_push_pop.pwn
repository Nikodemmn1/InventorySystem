
Its_Pop_By_Cat_Info(dbID, itsCategoryInfo[e_ITS_CATEGORY])
{
    if(!map_has_key(itsCategoryInfo[ITS_IDXMAP], dbID))
    {
        printf("Its_Pop - pod podanym dbID (%d) nie ma indeksu w pamiêci!", dbID);
        return 0;
    }

    new arrayIdx = map_get(itsCategoryInfo[ITS_IDXMAP], dbID);
    map_remove(itsCategoryInfo[ITS_IDXMAP], dbID);
    if(map_has_key(itsCategoryInfo[ITS_UPDATE_DIRTY], dbID))
    {
        map_remove(itsCategoryInfo[ITS_UPDATE_DIRTY], dbID);
    }
    itsCategoryInfo[ITS_COUNT] -= 1;

    list_add(itsCategoryInfo[ITS_HOLES], arrayIdx);

    return 1;
}

Its_Pop(dbID, categoryID)
{
    return Its_Pop_By_Cat_Info(dbID, itsCategories[categoryID]);
}

Its_Pop_By_Tag(dbID, const tag[])
{
    return Its_Pop(dbID, map_str_get(itsCategoryIDByTag, tag));
}

Its_Push(dbID, const inputArray[], itsCategoryInfo[e_ITS_CATEGORY])
{
    new arrayIdx;

    if(map_has_key(itsCategoryInfo[ITS_IDXMAP], dbID))
    {
        printf("Its_Push - pod podanym dbID (%d) jest juz indeks w pamiêci!", dbID);
        return 0;
    }

    if(itsCategoryInfo[ITS_COUNT] == itsCategoryInfo[ITS_SIZE])
    {
        new oldSize = itsCategoryInfo[ITS_SIZE];
        itsCategoryInfo[ITS_SIZE] *= 2;
        new UnmanagedPointer:oldDynamicArr = itsCategoryInfo[ITS_ARR];
        itsCategoryInfo[ITS_ARR] = MEM_UM_new_zero(itsCategoryInfo[ITS_SIZE] * itsCategoryInfo[ITS_ELEM_SIZE]);
        MEM_UM_copy(itsCategoryInfo[ITS_ARR], oldDynamicArr, oldSize * itsCategoryInfo[ITS_ELEM_SIZE]);
        MEM_UM_delete(oldDynamicArr);
    }

    if(list_size(itsCategoryInfo[ITS_HOLES]) == 0)
    {
        arrayIdx = itsCategoryInfo[ITS_COUNT];
    }
    else
    {
        arrayIdx = list_get(itsCategoryInfo[ITS_HOLES], 0);
        list_remove(itsCategoryInfo[ITS_HOLES], 0);
    }
    itsCategoryInfo[ITS_COUNT]++;

    map_add(itsCategoryInfo[ITS_IDXMAP], dbID, arrayIdx);
    MEM_UM_set_arr(itsCategoryInfo[ITS_ARR], arrayIdx * itsCategoryInfo[ITS_ELEM_SIZE], inputArray, itsCategoryInfo[ITS_ELEM_SIZE]);

    return 1;
}

Its_Push_IC(dbID, classID, isContainer)
{
    new inputArray[e_ITS_ITEM_OR_CONTAINER];
    inputArray[ITS_IC_DBID] = dbID; inputArray[ITS_IC_CLASSID] = classID; inputArray[ITS_IC_ISCONTAINER] = isContainer;
    return Its_Push(dbID, inputArray, itsCategoriesByTag["IC"]);
}

Its_Push_BC(dbID, List:containedItems, takenSpace)
{
    new inputArray[e_ITS_BASIC_CONTAINER];
    inputArray[ITS_BC_DBID] = dbID; inputArray[ITS_BC_CONT_ITEMS] = containedItems; inputArray[ITS_BC_TAKEN_SPACE] = takenSpace;
    return Its_Push(dbID, inputArray, itsCategoriesByTag["BC"]);
}

Its_Push_BI(dbID, isEquipped, parentContainer)
{
    new inputArray[e_ITS_BASIC_ITEM];
    inputArray[ITS_BI_ITEM_DBID] = dbID; inputArray[ITS_BI_PARENTCONTAINER] = parentContainer; inputArray[ITS_BI_ISEQUIPPED] = isEquipped;
    return Its_Push(dbID, inputArray, itsCategoriesByTag["BI"]);
}

Its_Push_POS(dbID, Float:x, Float:y, Float:z, interior, vw, ownerID = ITS_NULL)
{
    new inputArray[e_ITS_IC_POS];
    inputArray[ITS_POS_DBID] = dbID; inputArray[ITS_POS_X] = x; inputArray[ITS_POS_Y] = y; inputArray[ITS_POS_Z] = z;
    inputArray[ITS_POS_INTERIOR] = interior; inputArray[ITS_POS_VW] = vw; inputArray[ITS_POS_OWNERID] = ownerID;
    inputArray[ITS_POS_OBJECTID] = ITS_NULL; inputArray[ITS_POS_3DTEXTID] = ITS_NULL;
    return Its_Push(dbID, inputArray, itsCategoriesByTag["POS"]);
}

Its_Push_PC(dbID, uid)
{
    new inputArray[e_ITS_PLAYER_CONTAINER];
    inputArray[ITS_PC_DBID] = dbID; inputArray[ITS_PC_UID] = uid;
    return Its_Push(dbID, inputArray, itsCategoriesByTag["PC"]);
}

Its_Push_SPMOD(dbID, modelID)
{
    new inputArray[e_ITS_SPECIAL_MODEL];
    inputArray[ITS_SPMOD_DBID] = dbID; inputArray[ITS_SPMOD_MODELID] = modelID;
    return Its_Push(dbID, inputArray, itsCategoriesByTag["SPMOD"]);
}