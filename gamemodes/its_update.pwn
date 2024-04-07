#include <file> //TODO: USUÑ!!!

__Its_MassUpdate_Common(query[UPDATE_QUERY_SIZE], itsCategoryInfo[e_ITS_CATEGORY], Func:qBuildFunc<dddas>)
{
    new columnCount = list_size(itsCategoryInfo[ITS_SQL_COLUMNS]);
    new updateTmpQuerySize = UPDATE_QUERY_SIZE / (columnCount + 1);
    new UnmanagedPointer:tmpQueries = MEM_UM_new_zero(UPDATE_QUERY_SIZE);
    new tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1];
    new tmpStr[UPDATE_QUERY_SIZE], tmpStrLen;

    new thisBatchSize;
    new Iter:icIter=map_iter(itsCategoryInfo[ITS_IDXMAP]);

    while(iter_inside(icIter))
    {
        MEM_UM_zero(tmpQueries, UPDATE_QUERY_SIZE);
        for(new i = 0; i < columnCount; i++)
        {
            list_get_str(itsCategoryInfo[ITS_SQL_COLUMNS], i, tmpStr, ITS_SQL_COLUMN_MAX_LEN);
            format(tmpStr, sizeof(tmpStr), "%s = CASE ID ", tmpStr);
            tmpStrLen = strlen(tmpStr);
            MEM_UM_set_arr(tmpQueries, i * updateTmpQuerySize, tmpStr, tmpStrLen);
            tmpQueriesLens[i] = tmpStrLen;
        }

        format(query, sizeof(query), "UPDATE `%s` SET ", itsCategoryInfo[ITS_CAT_TABLENAME]);

        format(tmpStr, sizeof(tmpStr), "WHERE ID IN (");
        tmpStrLen = strlen(tmpStr);
        MEM_UM_set_arr(tmpQueries, columnCount * updateTmpQuerySize, tmpStr, tmpStrLen);
        tmpQueriesLens[columnCount] = tmpStrLen;

        thisBatchSize = 0;

        for(new i = 0; i < UPDATE_BULK_SIZE && iter_inside(icIter); i++, iter_move_next(icIter))
        {
            new dbID = iter_get_key(icIter);
            if(!map_has_key(itsCategoryInfo[ITS_IDXMAP], dbID) || !map_has_key(itsCategoryInfo[ITS_UPDATE_DIRTY], dbID))
            {
                continue;
            }

            map_remove(itsCategoryInfo[ITS_UPDATE_DIRTY], dbID);

            @.qBuildFunc(dbID, updateTmpQuerySize, _:tmpQueries, tmpQueriesLens, tmpStr);
            
            format(tmpStr, sizeof(tmpStr), "%d,", dbID);
            tmpStrLen = strlen(tmpStr);
            MEM_UM_set_arr(tmpQueries, columnCount * updateTmpQuerySize + tmpQueriesLens[columnCount], tmpStr, tmpStrLen);
            tmpQueriesLens[columnCount] += tmpStrLen;

            MEM_UM_get_arr(tmpQueries, updateTmpQuerySize * columnCount, tmpStr, updateTmpQuerySize);

            thisBatchSize++;
        }

        if(thisBatchSize > 0)
        {
            for(new i = 0; i < columnCount + 1; i++)
            {
                if(i != columnCount) // gdy nie WHERE ID IN (...), to dopisz na koñcu END (domknij CASE)
                {
                    format(tmpStr, sizeof(tmpStr), "END");
                    if(i != columnCount - 1)
                    {
                        strcat(tmpStr, ",");
                    }
                    strcat(tmpStr, " ");

                    MEM_UM_set_arr(tmpQueries, updateTmpQuerySize * i + tmpQueriesLens[i], tmpStr, strlen(tmpStr));
                }

                MEM_UM_get_arr(tmpQueries, updateTmpQuerySize * i, tmpStr, updateTmpQuerySize);

                strcat(query, tmpStr);
            }
            query[strlen(query) - 1] = ')'; // domkniêcie WHERE ID IN (...)

            if(!mysql_query(query))
            {
                printf("Blad MySql w Its_MassUpdate(): errno %d!", mysql_errno());
                SendRconCommand("exit");
                return 0;
            }
        }
    }

    return 1;
}

#pragma warning push
#pragma warning disable 202
#pragma warning disable 213
Its_MassUpdate()
{
    new query[UPDATE_QUERY_SIZE];
    Its_MassInsert();

    __Its_MassUpdate_Common(query, itsCategoriesByTag["IC"], addressof(Its_IC_UpdQBuild<dddas>));
    __Its_MassUpdate_Common(query, itsCategoriesByTag["BI"], addressof(Its_BI_UpdQBuild<dddas>));
    __Its_MassUpdate_Common(query, itsCategoriesByTag["POS"], addressof(Its_POS_UpdQBuild<dddas>));
    __Its_MassUpdate_Common(query, itsCategoriesByTag["PC"], addressof(Its_PC_UpdQBuild<dddas>));
    __Its_MassUpdate_Common(query, itsCategoriesByTag["SPMOD"], addressof(Its_PC_UpdQBuild<dddas>));
    __Its_MassUpdate_Common(query, itsCategoriesByTag["ATP"], addressof(Its_ATP_UpdQBuild<dddas>));

    return 1;
}
#pragma warning pop