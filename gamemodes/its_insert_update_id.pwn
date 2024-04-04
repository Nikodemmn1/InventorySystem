Its_MassInsertIdUpdate_Common(const categoryInfo[e_ITS_CATEGORY], oldDbId, newDbId)
{
    if(!map_has_key(categoryInfo[ITS_IDXMAP], oldDbId))
    {
        return 0;
    }

    new idx = map_get(categoryInfo[ITS_IDXMAP], oldDbId);
    map_remove(categoryInfo[ITS_IDXMAP], oldDbId);
    map_remove(categoryInfo[ITS_UPDATE_DIRTY], oldDbId);

    MEM_UM_set_val(categoryInfo[ITS_ARR], categoryInfo[ITS_ELEM_SIZE] * idx, newDbId);
    map_add(categoryInfo[ITS_IDXMAP], newDbId, idx);

    return 1;
}

Its_MassInsertIdUpdate_IC(oldDbId, newDbId)
{
    if(!Its_MassInsertIdUpdate_Common(itsCategoriesByTag["IC"], oldDbId, newDbId))
    {
        printf("Blad krytyczny - proba Its_MassInsertIdUpdate_IC() o oldDbId %d, ale IC o takim oldDbId nie istnieje w pamieci!", oldDbId);
        SendRconCommand("exit");
        return 0;
    }

    return 1;
}

Its_MassInsertIdUpdate_BC(oldDbId, newDbId)
{
    if(Its_MassInsertIdUpdate_Common(itsCategoriesByTag["BC"], oldDbId, newDbId))
    {
        new List:containedItems = List:Its_Get(newDbId, ITS_BC_CONT_ITEMS);
        for(new i = 0; i < list_size(containedItems); i++)
        {
            Its_Set(list_get(containedItems, i), ITS_BI_PARENTCONTAINER, newDbId);
        }
    }

    return 1;
}

Its_MassInsertIdUpdate_BI(oldDbId, newDbId)
{
    if(Its_MassInsertIdUpdate_Common(itsCategoriesByTag["BI"], oldDbId, newDbId))
    {
        new parentContainerDbId = Its_Get(newDbId, ITS_BI_PARENTCONTAINER);
        if(parentContainerDbId != ITS_NULL)
        {
            new List:parentContainedList = List:Its_Get(parentContainerDbId, ITS_BC_CONT_ITEMS);
            new parentContainedListIdx = list_find(parentContainedList, oldDbId);
            list_set(parentContainedList, parentContainedListIdx, newDbId);
        }
    }
}

Its_MassInsertIdUpdate(List:newDbIds)
{
    new newDbId;
    for(new uninsDbId = firstUninsertedDbId; uninsDbId < nextUninsertedDbId; uninsDbId++)
    {
        newDbId = list_get(newDbIds, uninsDbId - firstUninsertedDbId);
        if(newDbId != ITS_NULL)
        {
            Its_MassInsertIdUpdate_IC(uninsDbId, newDbId);
            Its_MassInsertIdUpdate_BC(uninsDbId, newDbId);
            Its_MassInsertIdUpdate_BI(uninsDbId, newDbId);
            Its_MassInsertIdUpdate_Common(itsCategoriesByTag["POS"], uninsDbId, newDbId);
            Its_MassInsertIdUpdate_Common(itsCategoriesByTag["PC"], uninsDbId, newDbId);
            Its_MassInsertIdUpdate_Common(itsCategoriesByTag["SPMOD"], uninsDbId, newDbId);
        }
    }

    return 1;
}
