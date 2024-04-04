//#include <file> //TODO: WYWAL!!!

__Its_MassInsert_Additional(query[INSERT_QUERY_SIZE], itsCategoryInfo[e_ITS_CATEGORY], Func:qBuildFunc<dsd>)
{
    new insertTmpQ[INSERT_SINGLE_SIZE], thisBatchSize;
    new List:insertDbIds = itsCategoryInfo[ITS_TO_INSERT_ADDITIONAL], insertDbIdsIdx = 0;

    while(insertDbIdsIdx < list_size(insertDbIds))
    {
        format(query, sizeof(query), "INSERT INTO `%s` VALUES ", itsCategoryInfo[ITS_CAT_TABLENAME]);
        thisBatchSize = 0;

        for(new i = 0; i < INSERT_BULK_SIZE && insertDbIdsIdx < list_size(insertDbIds); i++, insertDbIdsIdx++)
        {
            new dbID = list_get(insertDbIds, insertDbIdsIdx);

            if(!map_has_key(itsCategoryInfo[ITS_IDXMAP], dbID))
            {
                    printf("Blad krytyczny - proba __Its_MassInsert_Additional() o dbID %d, ale %s o takim dbID nie istnieje w pamieci!", dbID, itsCategoryInfo[ITS_CAT_TAG]);
                    SendRconCommand("exit");
                    return -1;          
            }

            @.qBuildFunc(dbID, insertTmpQ, dbID);
            strcat(query, insertTmpQ);

            thisBatchSize++;
        }

        if(thisBatchSize > 0)
        {
            query[strlen(query) - 2] = 0;
            if(!mysql_query(query))
            {
                printf("Blad MySql w __Its_MassInsert_Additional(): errno %d!", mysql_errno());
                SendRconCommand("exit");
                return 0;
            }
        }
    }

    return 1;
}

__Its_MassInsert_Common(query[INSERT_QUERY_SIZE], List:newDbIds, itsCategoryInfo[e_ITS_CATEGORY], Func:qBuildFunc<dsd>, bool:addNewIds = false)
{
    new insertTmpQ[INSERT_SINGLE_SIZE];
    new uninsDbId = firstUninsertedDbId, thisBatchSize, newDbId, batchFirstUninsId;

    while(uninsDbId < nextUninsertedDbId)
    {
        format(query, sizeof(query), "INSERT INTO `%s` VALUES ", itsCategoryInfo[ITS_CAT_TABLENAME]);
        thisBatchSize = 0;
        batchFirstUninsId = uninsDbId;

        for(new i = 0; i < INSERT_BULK_SIZE && uninsDbId < nextUninsertedDbId; i++, uninsDbId++)
        {
            if(!map_has_key(itsCategoryInfo[ITS_IDXMAP], uninsDbId))
            {
                continue;
            }

            if(addNewIds)
            {
                newDbId = ITS_NULL;
            }
            else
            {
                newDbId = list_get(List:newDbIds, uninsDbId - firstUninsertedDbId);
            }

            @.qBuildFunc(uninsDbId, insertTmpQ, newDbId);
            strcat(query, insertTmpQ);

            thisBatchSize++;
        }

        if(thisBatchSize > 0)
        {
            query[strlen(query) - 2] = 0;
            if(!mysql_query(query))
            {
                printf("Blad MySql w __Its_MassInsert_Common(): errno %d!", mysql_errno());
                SendRconCommand("exit");
                return 0;
            }

            if(addNewIds)
            {
                newDbId  = mysql_insert_id();
                for(new oldId = batchFirstUninsId; oldId < uninsDbId; oldId++)
                {
                    if(!map_has_key(itsCategoryInfo[ITS_IDXMAP], oldId))
                    {
                        list_add(newDbIds, ITS_NULL);
                    }
                    else
                    {
                        list_add(newDbIds, newDbId++);
                    }
                }
            }
        }

    }

    return 1;
}

#pragma warning push
#pragma warning disable 202
#pragma warning disable 213
List:Its_MassInsert(freeNewDbIds = true, &Map:idTranslationMap = Map:ITS_NULL)
{
    new List:newDbIds = List:ITS_NULL;
    new query[INSERT_QUERY_SIZE];

    if(firstUninsertedDbId != nextUninsertedDbId)
    {
        newDbIds = list_new();

        __Its_MassInsert_Common(query, newDbIds, itsCategoriesByTag["IC"], addressof(Its_IC_InsQBuild<dsd>), true);
        __Its_MassInsert_Common(query, newDbIds, itsCategoriesByTag["BI"], addressof(Its_BI_InsQBuild<dsd>));
        __Its_MassInsert_Common(query, newDbIds, itsCategoriesByTag["PC"], addressof(Its_PC_InsQBuild<dsd>));
        __Its_MassInsert_Common(query, newDbIds, itsCategoriesByTag["POS"], addressof(Its_POS_InsQBuild<dsd>));
        __Its_MassInsert_Common(query, newDbIds, itsCategoriesByTag["SPMOD"], addressof(Its_SPMOD_InsQBuild<dsd>));

        Its_MassInsertIdUpdate(newDbIds);

        if(idTranslationMap != ITS_NULL)
        {
            idTranslationMap = map_new();
            for(new i = firstUninsertedDbId; i < nextUninsertedDbId; i++)
            {
                map_add(idTranslationMap, i, list_get(newDbIds, i - firstUninsertedDbId));
            }
        }

        firstUninsertedDbId = nextUninsertedDbId;

        if(freeNewDbIds)
        {
            list_delete(newDbIds);
        }
    }

    for(new Iter:icIter=map_iter(itsCategoryIDByTag);iter_inside(icIter);iter_move_next(icIter))
    {
        new catID = iter_get(icIter);
        new Func:insQBuildFunc<dsd> = Func:Its_GetCategoryInfo(catID, ITS_FUNC_INSERT_QBUILD)<dsd>;

        if(insQBuildFunc != Func:0<dsd>)
        {
            __Its_MassInsert_Additional(query, itsCategories[catID], insQBuildFunc);
            list_clear(itsCategories[catID][ITS_TO_INSERT_ADDITIONAL]);
        }
    }

    return newDbIds;
}
#pragma warning pop