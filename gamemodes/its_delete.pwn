Its_MassDeleteMysql()
{
    new query[DELETE_QUERY_SIZE], tmpStr[DELETE_SINGLE_SIZE];

    for(new Iter:icIter=map_iter(itsCategoryIDByTag);iter_inside(icIter);iter_move_next(icIter))
    {
        new categoryID = iter_get(icIter);
        new listIdx = 0;

        while(listIdx < list_size(itsCategories[categoryID][ITS_TO_DELETE]))
        {
            format(query, sizeof(query), "DELETE FROM `%s` WHERE ID in (", itsCategories[categoryID][ITS_CAT_TABLENAME]);

            for(new i = 0; i < DELETE_BULK_SIZE && listIdx < list_size(itsCategories[categoryID][ITS_TO_DELETE]); i++, listIdx++)
            {
                format(tmpStr, sizeof(tmpStr), "%d,", list_get(itsCategories[categoryID][ITS_TO_DELETE], listIdx));
                strcat(query, tmpStr);
            }

            query[strlen(query) - 1] = ')';
            printf("MassDeleteMysql query: %s", query);
            if(!mysql_query(query))
            {
                printf("Blad MySql w Its_MassDeleteMysql(): errno %d!", mysql_errno());
                SendRconCommand("exit");
                return 0;
            }
        }
    }

    return 1;
}

Its_Delete_IC(dbID)
{
    printf("Its_Delete_IC dbID: %d", dbID);

    Its_Unload_IC(dbID);

    new cID = map_str_get(itsCategoryIDByTag, "POS");
    if(dbID < ITC_UNINSERTED)
    {
        list_add(itsCategories[cID][ITS_TO_DELETE], dbID);
    }

    return 1;
}

Its_Delete_BC(dbID)
{
    printf("Its_Delete_BC dbID: %d", dbID);
    Its_Delete_IC(dbID);
    Its_Unload_BC(dbID, false);
    return 1;
}

Its_Delete_BI(dbID)
{
    printf("Its_Delete_BI dbID: %d", dbID);
    Its_Unload_BI(dbID, false);
    Its_Delete_IC(dbID);
    return 1;
}

Its_Delete_POS(dbID)
{
    printf("Its_Delete_POS dbID: %d", dbID);

    Its_Unload_POS(dbID, false);

    new cID = map_str_get(itsCategoryIDByTag, "POS");
    if(dbID < ITC_UNINSERTED)
    {
        list_add(itsCategories[cID][ITS_TO_DELETE], dbID);
    }

    return 1;
}

Its_Delete_PC(dbID)
{
    printf("Its_Delete_PC dbID: %d", dbID);

    Its_Unload_PC(dbID, false);
    Its_Delete_BC(dbID);
    
    return 1;
}

Its_Delete_SPMOD(dbID)
{
    printf("Its_Delete_SPMOD dbID: %d", dbID);

    Its_Unload_SPMOD(dbID, false);

    new cID = map_str_get(itsCategoryIDByTag, "SPMOD");
    if(dbID < ITC_UNINSERTED)
    {
        list_add(itsCategories[cID][ITS_TO_DELETE], dbID);
    }

    return 1;
}
